@echo off
echo Initializing MySQL database for nav...
echo.

REM 检查 MySQL 是否在运行
echo Checking MySQL connection...
mysql -u root -plh116688257 -e "SELECT 'MySQL is running' as status;" 2>nul
if errorlevel 1 (
    echo ERROR: Cannot connect to MySQL. Please make sure MySQL is running on port 3306.
    pause
    exit /b 1
)

echo MySQL connection successful!
echo.

REM 执行初始化脚本
echo Creating database and tables...
mysql -u root -plh116688257 < init-mysql.sql
if errorlevel 1 (
    echo ERROR: Failed to initialize database.
    pause
    exit /b 1
)

echo.
echo Database initialized successfully!
echo.
echo Database: nav
echo User: nav
echo Password: lh116688257
echo.

REM 验证数据库是否创建成功
echo Verifying database...
mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;"
if errorlevel 1 (
    echo ERROR: Failed to verify database.
    pause
    exit /b 1
)

echo.
echo All done! You can now start the application with: docker-compose up -d
pause
