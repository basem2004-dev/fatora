package com.example.fatora

import android.app.DownloadManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.os.ParcelFileDescriptor
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import org.apache.commons.compress.compressors.bzip2.BZip2CompressorInputStream
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.TimeUnit

private const val VOICE_MODEL_URL =
    "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/" +
        "sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25.tar.bz2"
private const val VOICE_MODEL_ARCHIVE = "fatora-qwen3-asr.tar.bz2"
private const val VOICE_MODEL_FOLDER = "sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25"
private const val VOICE_MODEL_DOWNLOAD_PREFS = "voice_model_downloads"
private const val VOICE_MODEL_DOWNLOAD_ID = "qwen3_download_id"
private const val VOICE_MODEL_INSTALL_WORK = "install_qwen3_voice_model"

class VoiceModelDownloadManager(context: Context) {
    private val appContext = context.applicationContext
    private val systemDownloadManager =
        appContext.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
    private val preferences =
        appContext.getSharedPreferences(VOICE_MODEL_DOWNLOAD_PREFS, Context.MODE_PRIVATE)

    fun startOrResume(): Long {
        if (VoiceModelFiles.isInstalled(appContext)) return -1L

        val savedId = preferences.getLong(VOICE_MODEL_DOWNLOAD_ID, -1L)
        val savedDownload = if (savedId >= 0L) readDownload(savedId) else null
        if (savedDownload != null) {
            if (savedDownload.status == DownloadManager.STATUS_PENDING ||
                savedDownload.status == DownloadManager.STATUS_RUNNING ||
                savedDownload.status == DownloadManager.STATUS_PAUSED
            ) {
                return savedId
            }
            if (savedDownload.status == DownloadManager.STATUS_SUCCESSFUL) {
                enqueueInstall(savedId, replaceFailedWork = true)
                return savedId
            }
            systemDownloadManager.remove(savedId)
        }

        val request = DownloadManager.Request(Uri.parse(VOICE_MODEL_URL))
            .setTitle("تنزيل نموذج الصوت لفاتورة")
            .setDescription("يستمر التنزيل بالخلفية ويستأنف عند عودة الإنترنت")
            .setAllowedOverMetered(true)
            .setAllowedOverRoaming(false)
            .setNotificationVisibility(
                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED,
            )
            .setDestinationInExternalFilesDir(
                appContext,
                Environment.DIRECTORY_DOWNLOADS,
                VOICE_MODEL_ARCHIVE,
            )

        val downloadId = systemDownloadManager.enqueue(request)
        preferences.edit().putLong(VOICE_MODEL_DOWNLOAD_ID, downloadId).apply()
        return downloadId
    }

    fun getStatus(): Map<String, Any?> {
        val modelDirectory = VoiceModelFiles.modelDirectory(appContext)
        if (VoiceModelFiles.isInstalled(appContext)) {
            return statusMap("installed", modelDirectory = modelDirectory.absolutePath)
        }

        val downloadId = preferences.getLong(VOICE_MODEL_DOWNLOAD_ID, -1L)
        if (downloadId < 0L) return statusMap("idle")

        val download = readDownload(downloadId)
            ?: return statusMap("idle")

        if (download.status == DownloadManager.STATUS_SUCCESSFUL) {
            val installInfo = readInstallInfo(downloadId)
            if (installInfo?.state == WorkInfo.State.FAILED) {
                val reason = installInfo.outputData.getString("reason")
                    ?: "تعذر تجهيز ملفات نموذج الصوت. أعد المحاولة."
                return statusMap("failed", message = reason)
            }
            if (installInfo?.state == WorkInfo.State.CANCELLED) {
                return statusMap("failed", message = "أُوقف تجهيز نموذج الصوت. اضغط لإعادة المحاولة.")
            }
            if (installInfo?.state == WorkInfo.State.SUCCEEDED) {
                return statusMap(
                    "failed",
                    message = "لم تكتمل ملفات نموذج الصوت. اضغط لإعادة المحاولة.",
                )
            }
            enqueueInstall(downloadId)
            return statusMap("installing")
        }

        return when (download.status) {
            DownloadManager.STATUS_PENDING -> statusMap(
                "queued",
                downloadId = downloadId,
                downloadedBytes = download.downloadedBytes,
                totalBytes = download.totalBytes,
            )
            DownloadManager.STATUS_RUNNING -> statusMap(
                "downloading",
                downloadId = downloadId,
                downloadedBytes = download.downloadedBytes,
                totalBytes = download.totalBytes,
            )
            DownloadManager.STATUS_PAUSED -> statusMap(
                "waitingForNetwork",
                downloadId = downloadId,
                downloadedBytes = download.downloadedBytes,
                totalBytes = download.totalBytes,
                message = pauseMessage(download.reason),
            )
            DownloadManager.STATUS_FAILED -> statusMap(
                "failed",
                downloadId = downloadId,
                downloadedBytes = download.downloadedBytes,
                totalBytes = download.totalBytes,
                message = failureMessage(download.reason),
            )
            else -> statusMap("idle")
        }
    }

    fun handleDownloadComplete(downloadId: Long) {
        val savedId = preferences.getLong(VOICE_MODEL_DOWNLOAD_ID, -1L)
        if (downloadId != savedId) return
        val download = readDownload(downloadId) ?: return
        if (download.status == DownloadManager.STATUS_SUCCESSFUL) {
            enqueueInstall(downloadId)
        }
    }

    private fun readDownload(downloadId: Long): DownloadRecord? {
        val query = DownloadManager.Query().setFilterById(downloadId)
        return systemDownloadManager.query(query)?.use { cursor ->
            if (!cursor.moveToFirst()) return@use null
            DownloadRecord(
                status = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS)),
                reason = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON)),
                downloadedBytes = cursor.getLong(
                    cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR),
                ),
                totalBytes = cursor.getLong(
                    cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES),
                ),
            )
        }
    }

    private fun enqueueInstall(downloadId: Long, replaceFailedWork: Boolean = false) {
        if (VoiceModelFiles.isInstalled(appContext)) return
        val uniqueName = "$VOICE_MODEL_INSTALL_WORK-$downloadId"
        val input = Data.Builder().putLong(InstallVoiceModelWorker.DOWNLOAD_ID, downloadId).build()
        val request = OneTimeWorkRequestBuilder<InstallVoiceModelWorker>()
            .setInputData(input)
            .build()
        val policy = if (replaceFailedWork) ExistingWorkPolicy.REPLACE else ExistingWorkPolicy.KEEP
        WorkManager.getInstance(appContext).enqueueUniqueWork(uniqueName, policy, request)
    }

    private fun readInstallInfo(downloadId: Long): WorkInfo? {
        val uniqueName = "$VOICE_MODEL_INSTALL_WORK-$downloadId"
        return try {
            WorkManager.getInstance(appContext)
                .getWorkInfosForUniqueWork(uniqueName)
                .get(5, TimeUnit.SECONDS)
                .lastOrNull()
        } catch (_: Exception) {
            null
        }
    }

    private fun statusMap(
        state: String,
        downloadId: Long? = null,
        downloadedBytes: Long = 0L,
        totalBytes: Long = 0L,
        message: String = "",
        modelDirectory: String = "",
    ): Map<String, Any?> = mapOf(
        "state" to state,
        "downloadId" to downloadId,
        "downloadedBytes" to downloadedBytes,
        "totalBytes" to totalBytes,
        "message" to message,
        "modelDirectory" to modelDirectory,
    )

    private fun pauseMessage(reason: Int): String = when (reason) {
        DownloadManager.PAUSED_WAITING_FOR_NETWORK,
        DownloadManager.PAUSED_WAITING_TO_RETRY ->
            "الإنترنت مقطوع مؤقتًا. سيكمل التنزيل تلقائيًا عند عودته."
        DownloadManager.PAUSED_QUEUED_FOR_WIFI ->
            "التنزيل ينتظر اتصال واي فاي."
        DownloadManager.PAUSED_UNKNOWN ->
            "التنزيل متوقف مؤقتًا وسيحاول النظام استئنافه."
        else -> "التنزيل متوقف مؤقتًا؛ سيستأنف تلقائيًا."
    }

    private fun failureMessage(reason: Int): String = when (reason) {
        DownloadManager.ERROR_CANNOT_RESUME -> "تعذر استئناف الملف. اضغط لإعادة التنزيل."
        DownloadManager.ERROR_DEVICE_NOT_FOUND -> "مساحة التخزين غير متاحة. أعد المحاولة لاحقًا."
        DownloadManager.ERROR_INSUFFICIENT_SPACE -> "لا توجد مساحة كافية لتنزيل نموذج الصوت."
        DownloadManager.ERROR_HTTP_DATA_ERROR,
        DownloadManager.ERROR_UNHANDLED_HTTP_CODE -> "تعذر الاتصال بمصدر النموذج. اضغط لإعادة المحاولة."
        else -> "لم يكتمل التنزيل. اضغط لإعادة المحاولة."
    }

    private data class DownloadRecord(
        val status: Int,
        val reason: Int,
        val downloadedBytes: Long,
        val totalBytes: Long,
    )
}

private object VoiceModelFiles {
    private const val MODEL_DIRECTORY = "qwen3-asr"
    private const val MIN_CONV_FRONTEND_BYTES = 40L * 1024 * 1024
    private const val MIN_ENCODER_BYTES = 160L * 1024 * 1024
    private const val MIN_DECODER_BYTES = 700L * 1024 * 1024
    private const val MIN_VOCAB_BYTES = 2L * 1024 * 1024
    private const val MIN_MERGES_BYTES = 1L * 1024 * 1024

    fun modelDirectory(context: Context): File =
        File(File(context.filesDir, "voice_models"), MODEL_DIRECTORY)

    fun isInstalled(context: Context): Boolean = hasCompleteFiles(modelDirectory(context))

    fun hasCompleteFiles(directory: File): Boolean =
        hasExpectedSize(directory, "conv_frontend.onnx", MIN_CONV_FRONTEND_BYTES) &&
            hasExpectedSize(directory, "encoder.int8.onnx", MIN_ENCODER_BYTES) &&
            hasExpectedSize(directory, "decoder.int8.onnx", MIN_DECODER_BYTES) &&
            hasExpectedSize(directory, "tokenizer/vocab.json", MIN_VOCAB_BYTES) &&
            hasExpectedSize(directory, "tokenizer/merges.txt", MIN_MERGES_BYTES)

    private fun hasExpectedSize(directory: File, path: String, minimumBytes: Long): Boolean {
        val file = File(directory, path)
        return file.isFile && file.length() >= minimumBytes
    }
}

class VoiceModelDownloadReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != DownloadManager.ACTION_DOWNLOAD_COMPLETE) return
        val downloadId = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1L)
        if (downloadId >= 0L) {
            VoiceModelDownloadManager(context).handleDownloadComplete(downloadId)
        }
    }
}

class InstallVoiceModelWorker(context: Context, parameters: WorkerParameters) :
    Worker(context, parameters) {

    override fun doWork(): Result {
        val downloadId = inputData.getLong(DOWNLOAD_ID, -1L)
        if (downloadId < 0L) return Result.failure()

        val downloadManager =
            applicationContext.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        val cursor = downloadManager.query(DownloadManager.Query().setFilterById(downloadId))
            ?: return Result.retry()
        val downloadSucceeded = cursor.use {
            it.moveToFirst() &&
                it.getInt(it.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS)) ==
                DownloadManager.STATUS_SUCCESSFUL
        }
        if (!downloadSucceeded) return Result.retry()

        return try {
            setProgressAsync(Data.Builder().putString("stage", "installing").build())
            installDownloadedModel(downloadId, downloadManager)
            applicationContext
                .getSharedPreferences(VOICE_MODEL_DOWNLOAD_PREFS, Context.MODE_PRIVATE)
                .edit()
                .remove(VOICE_MODEL_DOWNLOAD_ID)
                .apply()
            downloadManager.remove(downloadId)
            Result.success()
        } catch (error: Exception) {
            if (error is IncompleteVoiceModelException) {
                // A successful DownloadManager status can still contain a truncated archive.
                // Remove it so the next retry starts a fresh download instead of unpacking it again.
                downloadManager.remove(downloadId)
            }
            val reason = when (error) {
                is IncompleteVoiceModelException ->
                    "وصل نموذج الصوت ناقصًا. اضغط لإعادة تنزيله."
                is IOException -> "تعذر قراءة ملفات النموذج. أعد تجهيزها من الإعدادات."
                else -> "تعذر تجهيز نموذج الصوت. أعد المحاولة من الإعدادات."
            }
            Result.failure(Data.Builder().putString("reason", reason).build())
        }
    }

    private fun installDownloadedModel(downloadId: Long, downloadManager: DownloadManager) {
        val modelsDirectory = File(applicationContext.filesDir, "voice_models")
        if (!modelsDirectory.exists() && !modelsDirectory.mkdirs()) {
            throw IOException("Could not create model directory")
        }

        val temporaryDirectory = File(modelsDirectory, "qwen3-asr-installing")
        if (temporaryDirectory.exists()) temporaryDirectory.deleteRecursively()
        if (!temporaryDirectory.mkdirs()) throw IOException("Could not prepare model directory")

        val descriptor = downloadManager.openDownloadedFile(downloadId)
        ParcelFileDescriptor.AutoCloseInputStream(descriptor).use { downloadStream ->
            BufferedInputStream(downloadStream).use { bufferedStream ->
                BZip2CompressorInputStream(bufferedStream, true).use { compressedStream ->
                    TarArchiveInputStream(compressedStream).use { tarStream ->
                        extractModelFiles(tarStream, temporaryDirectory)
                    }
                }
            }
        }

        requireModelFiles(temporaryDirectory)

        val finalDirectory = VoiceModelFiles.modelDirectory(applicationContext)
        if (finalDirectory.exists()) finalDirectory.deleteRecursively()
        if (!temporaryDirectory.renameTo(finalDirectory)) {
            throw IOException("Could not finish installing model")
        }
    }

    private fun extractModelFiles(tarStream: TarArchiveInputStream, destination: File) {
        val expectedFiles = setOf("conv_frontend.onnx", "encoder.int8.onnx", "decoder.int8.onnx")
        val safeDestination = destination.canonicalFile
        var entry = tarStream.nextEntry
        while (entry != null) {
            val normalizedName = entry.name.replace('\\', '/').trimStart('/')
            val modelPrefix = "$VOICE_MODEL_FOLDER/"
            val relativeName = when {
                normalizedName.startsWith(modelPrefix) -> normalizedName.removePrefix(modelPrefix)
                normalizedName == VOICE_MODEL_FOLDER -> ""
                else -> ""
            }
            val isModelFile = relativeName in expectedFiles || relativeName.startsWith("tokenizer/")

            if (isModelFile && !entry.isSymbolicLink && !entry.isLink) {
                val outputFile = File(destination, relativeName).canonicalFile
                if (!outputFile.path.startsWith(safeDestination.path + File.separator)) {
                    throw IOException("Invalid path in model archive")
                }
                if (entry.isDirectory) {
                    if (!outputFile.exists() && !outputFile.mkdirs()) {
                        throw IOException("Could not create model folder")
                    }
                } else {
                    outputFile.parentFile?.let { parent ->
                        if (!parent.exists() && !parent.mkdirs()) {
                            throw IOException("Could not create model folder")
                        }
                    }
                    FileOutputStream(outputFile).use { fileOutput -> tarStream.copyTo(fileOutput) }
                }
            }
            entry = tarStream.nextEntry
        }
    }

    private fun requireModelFiles(directory: File) {
        if (!VoiceModelFiles.hasCompleteFiles(directory)) {
            throw IncompleteVoiceModelException("Model archive has missing or truncated files")
        }
    }

    companion object {
        const val DOWNLOAD_ID = "voice_model_download_id"
    }
}

private class IncompleteVoiceModelException(message: String) : IOException(message)
