package com.example.fatora

import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private lateinit var ledgerDatabase: LedgerDatabase
    private val voiceModelExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ledgerDatabase = LedgerDatabase(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getEntries" -> result.success(ledgerDatabase.getEntries())
                        "getProfile" -> result.success(ledgerDatabase.getProfile())
                        "saveProfile" -> {
                            ledgerDatabase.saveProfile(call.arguments.asMap())
                            result.success(null)
                        }
                        "addEntry" -> result.success(ledgerDatabase.addEntry(call.arguments.asMap()))
                        "updateEntry" -> result.success(ledgerDatabase.updateEntry(call.arguments.asMap()))
                        "deleteEntry" -> result.success(ledgerDatabase.deleteEntry(call.arguments.asMap()))
                        "deleteCustomer" -> result.success(ledgerDatabase.deleteCustomer(call.arguments.asMap()))
                        "clear" -> {
                            ledgerDatabase.clear()
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("LEDGER_DATABASE_ERROR", error.message, null)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_MODEL_CHANNEL)
            .setMethodCallHandler { call, result ->
                voiceModelExecutor.execute {
                    try {
                        val manager = VoiceModelDownloadManager(applicationContext)
                        val response = when (call.method) {
                            "getStatus" -> manager.getStatus()
                            "startDownload" -> {
                                manager.startOrResume()
                                manager.getStatus()
                            }
                            else -> null
                        }
                        runOnUiThread {
                            if (response == null) result.notImplemented()
                            else result.success(response)
                        }
                    } catch (error: Exception) {
                        runOnUiThread {
                            result.error("VOICE_MODEL_ERROR", error.message, null)
                        }
                    }
                }
            }
    }

    private fun Any?.asMap(): Map<String, Any?> {
        @Suppress("UNCHECKED_CAST")
        return this as? Map<String, Any?> ?: emptyMap()
    }

    companion object {
        private const val CHANNEL = "com.example.fatora/ledger"
        private const val VOICE_MODEL_CHANNEL = "com.example.fatora/voice_model"
    }
}

private class LedgerDatabase(context: android.content.Context) :
    SQLiteOpenHelper(context, "fatora_ledger.db", null, DATABASE_VERSION) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """CREATE TABLE customers (
                name TEXT PRIMARY KEY COLLATE NOCASE,
                created_at TEXT NOT NULL
            )""".trimIndent(),
        )
        db.execSQL(
            """CREATE TABLE entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_name TEXT NOT NULL COLLATE NOCASE,
                amount REAL NOT NULL CHECK(amount > 0),
                type TEXT NOT NULL CHECK(type IN ('invoice', 'debt', 'payment')),
                created_at TEXT NOT NULL,
                product TEXT NOT NULL DEFAULT '',
                is_old_debt INTEGER NOT NULL DEFAULT 0,
                is_paid INTEGER NOT NULL DEFAULT 0
            )""".trimIndent(),
        )
        db.execSQL("CREATE INDEX entries_created_at_idx ON entries(created_at DESC)")
        db.execSQL("CREATE INDEX entries_customer_idx ON entries(customer_name)")
        createSettingsTable(db)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        if (oldVersion < 2) {
            db.execSQL("ALTER TABLE entries ADD COLUMN is_paid INTEGER NOT NULL DEFAULT 0")
        }
        if (oldVersion < 3) createSettingsTable(db)
    }

    private fun createSettingsTable(db: SQLiteDatabase) {
        db.execSQL(
            """CREATE TABLE app_settings (
                setting_key TEXT PRIMARY KEY,
                setting_value TEXT NOT NULL DEFAULT ''
            )""".trimIndent(),
        )
    }

    fun getProfile(): Map<String, String> {
        val profile = mutableMapOf("shopName" to "", "phone" to "")
        readableDatabase.rawQuery(
            "SELECT setting_key, setting_value FROM app_settings WHERE setting_key IN ('shopName', 'phone')",
            null,
        ).use { cursor ->
            while (cursor.moveToNext()) profile[cursor.getString(0)] = cursor.getString(1)
        }
        return profile
    }

    fun saveProfile(values: Map<String, Any?>) {
        val db = writableDatabase
        db.beginTransaction()
        try {
            listOf("shopName", "phone").forEach { key ->
                db.insertWithOnConflict(
                    "app_settings",
                    null,
                    ContentValues().apply {
                        put("setting_key", key)
                        put("setting_value", values[key]?.toString()?.trim() ?: "")
                    },
                    SQLiteDatabase.CONFLICT_REPLACE,
                )
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
    }

    fun getEntries(): List<Map<String, Any?>> {
        val rows = mutableListOf<Map<String, Any?>>()
        readableDatabase.rawQuery(
            "SELECT id, customer_name, amount, type, created_at, product, is_old_debt, is_paid FROM entries ORDER BY created_at DESC, id DESC",
            null,
        ).use { cursor ->
            while (cursor.moveToNext()) {
                rows += mapOf(
                    "id" to cursor.getLong(0),
                    "customerName" to cursor.getString(1),
                    "amount" to cursor.getDouble(2),
                    "type" to cursor.getString(3),
                    "createdAt" to cursor.getString(4),
                    "product" to cursor.getString(5),
                    "isOldDebt" to cursor.getInt(6),
                    "isPaid" to cursor.getInt(7),
                )
            }
        }
        return rows
    }

    fun addEntry(values: Map<String, Any?>): Long {
        val customerName = values.requiredString("customerName")
        val db = writableDatabase
        var newId = -1L
        db.beginTransaction()
        try {
            ensureCustomer(db, customerName)
            newId = db.insertOrThrow("entries", null, values.toContentValues())
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return newId
    }

    fun updateEntry(values: Map<String, Any?>): Boolean {
        val id = values.requiredLong("id")
        val db = writableDatabase
        db.beginTransaction()
        return try {
            ensureCustomer(db, values.requiredString("customerName"))
            val updated = db.update(
                "entries",
                values.toContentValues(),
                "id = ?",
                arrayOf(id.toString()),
            ) > 0
            removeUnusedCustomers(db)
            db.setTransactionSuccessful()
            updated
        } finally {
            db.endTransaction()
        }
    }

    fun deleteEntry(values: Map<String, Any?>): Boolean {
        val deleted = writableDatabase.delete(
            "entries",
            "id = ?",
            arrayOf(values.requiredLong("id").toString()),
        ) > 0
        removeUnusedCustomers(writableDatabase)
        return deleted
    }

    fun deleteCustomer(values: Map<String, Any?>): Int {
        val customerName = values.requiredString("customerName")
        val db = writableDatabase
        db.beginTransaction()
        return try {
            val deleted = db.delete(
                "entries",
                "customer_name = ? COLLATE NOCASE",
                arrayOf(customerName),
            )
            db.delete("customers", "name = ? COLLATE NOCASE", arrayOf(customerName))
            db.setTransactionSuccessful()
            deleted
        } finally {
            db.endTransaction()
        }
    }

    fun clear() {
        val db = writableDatabase
        db.beginTransaction()
        try {
            db.delete("entries", null, null)
            db.delete("customers", null, null)
            db.execSQL("DELETE FROM sqlite_sequence WHERE name = 'entries'")
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
    }

    private fun ensureCustomer(db: SQLiteDatabase, name: String) {
        db.insertWithOnConflict(
            "customers",
            null,
            ContentValues().apply {
                put("name", name.trim())
                put("created_at", System.currentTimeMillis().toString())
            },
            SQLiteDatabase.CONFLICT_IGNORE,
        )
    }

    private fun removeUnusedCustomers(db: SQLiteDatabase) {
        db.execSQL("DELETE FROM customers WHERE name NOT IN (SELECT DISTINCT customer_name FROM entries)")
    }

    private fun Map<String, Any?>.toContentValues(): ContentValues = ContentValues().apply {
        put("customer_name", requiredString("customerName").trim())
        put("amount", requiredDouble("amount"))
        put("type", requiredString("type"))
        put("created_at", requiredString("createdAt"))
        put("product", (this@toContentValues["product"] as? String)?.trim() ?: "")
        put("is_old_debt", if (this@toContentValues["isOldDebt"] == true) 1 else 0)
        put("is_paid", if (this@toContentValues["isPaid"] == true) 1 else 0)
    }

    private fun Map<String, Any?>.requiredString(key: String): String =
        (this[key] as? String)?.trim()?.takeIf { it.isNotEmpty() }
            ?: throw IllegalArgumentException("Missing $key")

    private fun Map<String, Any?>.requiredLong(key: String): Long =
        (this[key] as? Number)?.toLong() ?: throw IllegalArgumentException("Missing $key")

    private fun Map<String, Any?>.requiredDouble(key: String): Double =
        (this[key] as? Number)?.toDouble()?.takeIf { it > 0.0 }
            ?: throw IllegalArgumentException("Invalid $key")

    companion object {
        private const val DATABASE_VERSION = 3
    }
}
