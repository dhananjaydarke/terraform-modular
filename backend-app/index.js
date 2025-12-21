const express = require("express");
const sql = require("mssql");
const cors = require("cors");

const app = express();

const apiPrefix = process.env.API_PREFIX || "/api";
const allowedOrigin = process.env.ALLOWED_ORIGIN || "*";

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT || 1433),
  options: {
    encrypt: true,
    trustServerCertificate: true
  }
};

let poolPromise = null;

app.use(
  cors({
    origin: allowedOrigin === "*" ? "*" : [allowedOrigin],
    methods: ["GET"],
    credentials: false
  })
);

async function getPool() {
  if (!poolPromise) {
    poolPromise = sql.connect(config);
  }
  return poolPromise;
}

app.get(`${apiPrefix}/health`, (_req, res) => {
  res.json({ status: "ok" });
});

app.get(`${apiPrefix}/students`, async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query("SELECT RollNo, Name, Grade, DOB FROM Students ORDER BY RollNo");
    res.json(result.recordset);
  } catch (err) {
    console.error("DB error", err);
    res.status(500).json({ error: "Database error" });
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Students backend listening on port ${port}`);
});