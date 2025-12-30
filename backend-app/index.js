const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");

const app = express();

const apiPrefix = process.env.API_PREFIX || "/api";
const allowedOrigin = process.env.ALLOWED_ORIGIN || "*";

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: { rejectUnauthorized: false }
});

app.use(
  cors({
    origin: allowedOrigin === "*" ? "*" : [allowedOrigin],
    methods: ["GET"],
    credentials: false
  })
);



app.get(`${apiPrefix}/health`, (_req, res) => {
  res.json({ status: "ok" });
});

app.get(`${apiPrefix}/students`, async (req, res) => {
  try {
    const result = await pool.query('SELECT "RollNo", "Name", "Grade", "DOB" FROM "Students" ORDER BY "RollNo"');
    res.json(result.rows);
	} catch (err) {
    console.error("DB error", err);
    res.status(500).json({ error: "Database error" });
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Students backend listening on port ${port}`);
});
