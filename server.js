const express = require('express');
const sqlite3 = require('sqlite3');
const { open } = require('sqlite');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

async function setupDatabase() {
    const db = await open({
        filename: './rbe_pos.db',
        driver: sqlite3.Database
    });

    await db.exec(`
        CREATE TABLE IF NOT EXISTS transactions (
            id TEXT PRIMARY KEY,
            time TEXT NOT NULL,
            kasir TEXT NOT NULL,
            total INTEGER NOT NULL,
            total_hpp INTEGER NOT NULL,
            profit INTEGER NOT NULL,
            method TEXT NOT NULL,
            voided BOOLEAN DEFAULT 0
        );

        CREATE TABLE IF NOT EXISTS transaction_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id TEXT,
            item_name TEXT NOT NULL,
            price INTEGER NOT NULL,
            qty INTEGER NOT NULL,
            notes TEXT,
            FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
        );
    `);
    return db;
}

let dbInstance;
setupDatabase().then(db => {
    dbInstance = db;
    console.log("Database SQLite berhasil disiapkan!");
});

app.post('/api/transactions', async (req, res) => {
    const { id, time, kasir, items, total, totalHpp, profit, method } = req.body;
    try {
        await dbInstance.run('BEGIN TRANSACTION');

        await dbInstance.run(
            `INSERT INTO transactions (id, time, kasir, total, total_hpp, profit, method, voided) VALUES (?, ?, ?, ?, ?, ?, ?, 0)`,
            [id, time, kasir, total, totalHpp, profit, method]
        );

        for (let item of items) {
            await dbInstance.run(
                `INSERT INTO transaction_items (transaction_id, item_name, price, qty, notes) VALUES (?, ?, ?, ?, ?)`,
                [id, item.name, item.price, item.qty, item.notes || '']
            );
        }

        await dbInstance.run('COMMIT');
        res.status(201).json({ success: true, message: 'Transaksi berhasil disimpan ke SQLite!' });
    } catch (err) {
        await dbInstance.run('ROLLBACK');
        console.error(err);
        res.status(500).json({ success: false, error: err.message });
    }
});

app.get('/api/transactions', async (req, res) => {
    try {
        const txRows = await dbInstance.all('SELECT * FROM transactions ORDER BY time DESC');
        let transactions = [];
        for (let tx of txRows) {
            const itemRows = await dbInstance.all('SELECT * FROM transaction_items WHERE transaction_id = ?', [tx.id]);
            transactions.push({ ...tx, items: itemRows });
        }
        res.json({ success: true, data: transactions });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

app.listen(3000, () => {
    console.log('Server berjalan di http://localhost:3000');
});
