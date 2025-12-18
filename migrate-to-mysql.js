#!/usr/bin/env node

/**
 * SQLite to MySQL 数据迁移脚本
 * 从 prisma/dev.db 读取数据并导入到 MySQL 数据库
 */

const sqlite3 = require('sqlite3').verbose();
const mysql = require('mysql2/promise');
const path = require('path');

// MySQL 配置
const MYSQL_CONFIG = {
  host: 'localhost',
  port: 3306,
  user: 'nav',
  password: 'lh116688257',
  database: 'nav'
};

// SQLite 数据库路径
const SQLITE_DB_PATH = path.join(__dirname, 'prisma', 'dev.db');

// 颜色输出
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// 读取 SQLite 数据
function readSQLiteData(tableName) {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(SQLITE_DB_PATH, sqlite3.OPEN_READONLY, (err) => {
      if (err) {
        reject(err);
        return;
      }
    });

    db.all(`SELECT * FROM ${tableName}`, [], (err, rows) => {
      if (err) {
        reject(err);
        return;
      }
      db.close();
      resolve(rows);
    });
  });
}

// 获取表结构信息
function getTableInfo(tableName) {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(SQLITE_DB_PATH, sqlite3.OPEN_READONLY, (err) => {
      if (err) {
        reject(err);
        return;
      }
    });

    db.all(`PRAGMA table_info(${tableName})`, [], (err, rows) => {
      if (err) {
        reject(err);
        return;
      }
      db.close();
      resolve(rows);
    });
  });
}

// 转换 SQLite 值到 MySQL
function convertValue(value, columnType) {
  if (value === null || value === undefined) {
    return null;
  }

  // 布尔值转换
  if (columnType === 'BOOLEAN' || columnType === 'TINYINT') {
    return value === 1 || value === true ? 1 : 0;
  }

  return value;
}

// 将数据插入 MySQL
async function insertIntoMySQL(connection, tableName, data) {
  if (data.length === 0) {
    log(`  表 ${tableName} 无数据`, 'yellow');
    return;
  }

  const columns = Object.keys(data[0]);
  const placeholders = columns.map(() => '?').join(', ');
  const sql = `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES (${placeholders})`;

  let successCount = 0;
  let errorCount = 0;

  for (const row of data) {
    try {
      const values = columns.map(col => convertValue(row[col], typeof row[col]));
      await connection.execute(sql, values);
      successCount++;
    } catch (error) {
      errorCount++;
      log(`    插入失败: ${error.message}`, 'red');
    }
  }

  log(`  成功: ${successCount} 条, 失败: ${errorCount} 条`, successCount > 0 ? 'green' : 'red');
}

// 主函数
async function migrate() {
  log('========================================', 'blue');
  log('开始数据迁移: SQLite -> MySQL', 'blue');
  log('========================================', 'blue');

  let connection;

  try {
    // 检查 SQLite 数据库是否存在
    const fs = require('fs');
    if (!fs.existsSync(SQLITE_DB_PATH)) {
      throw new Error(`SQLite 数据库不存在: ${SQLITE_DB_PATH}`);
    }

    log('\n1. 连接到 MySQL 数据库...', 'blue');
    connection = await mysql.createConnection(MYSQL_CONFIG);
    log('   连接成功!', 'green');

    // 定义需要迁移的表
    const tables = [
      'Site',
      'Category',
      'User',
      'GlobalSettings',
      'Wallpaper',
      'CustomFont',
      'Todo',
      'Countdown'
    ];

    log('\n2. 开始迁移数据...', 'blue');

    for (const table of tables) {
      log(`\n正在迁移表: ${table}`, 'yellow');

      try {
        // 读取 SQLite 数据
        const data = await readSQLiteData(table);
        log(`  从 SQLite 读取 ${data.length} 条记录`, 'blue');

        // 清空 MySQL 表
        await connection.execute(`DELETE FROM ${table}`);
        log(`  清空 MySQL 表`, 'blue');

        // 插入数据
        await insertIntoMySQL(connection, table, data);
      } catch (error) {
        log(`  迁移失败: ${error.message}`, 'red');
      }
    }

    log('\n========================================', 'blue');
    log('数据迁移完成!', 'green');
    log('========================================', 'blue');

  } catch (error) {
    log('\n========================================', 'red');
    log(`迁移失败: ${error.message}`, 'red');
    log('========================================', 'red');
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// 运行迁移
if (require.main === module) {
  migrate();
}

module.exports = { migrate };
