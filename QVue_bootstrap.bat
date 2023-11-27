@echo off
chcp 65001
setlocal enabledelayedexpansion

rem :menu
cls
color 0A
echo '---------------------------------------'
echo              QVuePj 1.0                     
echo '---------------------------------------'

echo.
REM 获取时间
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set datetime=%%a
set year=%datetime:~2,2%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
echo 当前时间-%year%_%month%_%day%_%hour%%minute%


echo '--------------------------------------------------------'

REM 检查 Node.js 和 npm 安装
where node > nul 2>nul
if %errorlevel% neq 0 (
  echo 请先安装 Node.js，然后重新运行此脚本。
  exit /b 1
)

echo [V] 已检测到node！

where npm > nul 2>nul
if %errorlevel% neq 0 (
  echo 请先安装 npm，然后重新运行此脚本。
  exit /b 1
)

REM 检查 cnpm 是否安装
where cnpm > nul 2>nul
if %errorlevel% neq 0 (
  echo cnpm 尚未安装，正在使用 npm 安装 cnpm，请稍等...
  npm install -g cnpm --registry=https://registry.npm.taobao.org
  REM 再次检查 cnpm 是否安装
  where cnpm > nul 2>nul
  if %errorlevel% neq 0 (
    echo cnpm 安装失败，请手动安装 cnpm，并重新运行此脚本。
    exit /b 1
  )
  echo cnpm 安装成功！
)

echo [V] 已检测到cnpm！

color 07

echo 当前工作目录: %CD%

echo '--------------------------------------------------------'
REM 设置默认项目名称
set "defaultProjectName=vue_pj_test_-%year%_%month%_%day%_%hour%%minute%"

REM 提示用户输入项目名称
set /p "projectName=[?]请输入小写开头的英文的项目名称 [默认值 %defaultProjectName%]: "

REM 如果用户未输入，则使用默认项目名称
if not defined projectName set "projectName=%defaultProjectName%"

:validateProjectName
REM 使用 PowerShell 检查是否包含中文字符
for /f %%a in ('powershell -command "[regex]::IsMatch('!projectName!', '[\p{IsCJKUnifiedIdeographs}]')"') do set "containsChinese=%%a"

REM 替换项目名称中的空格为下划线
set "projectName=!projectName: =_!"

if not !containsChinese! == True (
    echo 项目名称: !projectName!
) else (
    echo [!]错误！禁止中文字符作为项目名称！请重新输入！
    set /p "projectName=[?]请输入小写字母和数字的项目名称 [默认值 %defaultProjectName%]: "
    goto :validateProjectName
)


rem 如果用户输入 将用户输入的项目名称一律转换为小写
if defined projectName set "projectName=!projectName:~0,1!!projectName:~1!"


echo '--------------------------------------------------------'
echo 创建VUE工程目录
REM 使用 cnpm 创建 Vue 项目
echo 正在使用 cnpm create vue [:]创建项目，请稍等...
call cnpm create vue@latest "%projectName%"

echo '--------------------------------------------------------'

cd "%projectName%"
echo 当前工作目录: %CD%
REM 安装项目依赖
echo [:]正在安装项目依赖，请稍等...
call cnpm install

echo '--------------------------------------------------------'



REM 询问用户是否安装 Bootstrap UI 框架
set /p "installBootstrap= [?]是否安装 Bootstrap UI 框架？ (yes/no): " || set "installBootstrap=yes"
if /i "%installBootstrap%"=="yes" (
  echo [:]开始安装 Bootstrap...
  
  echo [:]先安装Bootstrap最新版本需要的peer依赖包
  call cnpm i @popperjs/core
  
  echo [:]正在安装 Bootstrap...\
  call cnpm i bootstrap
  echo 完成 Bootstrap 的安装。
  

  echo 正在安装 Bootstrap 依赖 Sass...
  call cnpm i sass 
  echo 完成 Sass 的安装。
  
   echo [:]开始安装 Bootstrap ICONS...
  call cnpm i bootstrap-icons
  echo 完成 Bootstrap ICONS 的安装。
  
  
  
  echo '--------------------------------------------------------'
  echo 整理成空白的代码工程
  
  
rem  REM 删除 src/component/ 目录下的文件,不包含目录
rem del /Q "src\components\*" 2>nul


echo 当前工作目录: %CD%
echo 清理文件中...

REM 删除 src/component/ 目录及其所有内容
rd /s /q "src\components" 2>nul

REM 删除 src/assets/ 目录及其所有内容
rd /s /q "src\assets" 2>nul

REM 创建空的 src/component/ 和 src/assets/ 目录
mkdir "src\component" 2>nul
mkdir "src\assets" 2>nul

REM c创建空白main.css，并在其中写入想要写入的内容
echo /* Your CSS content here */ > "src\assets\main.css"
echo /* Additional CSS content */ >> "src\assets\main.css"

REM 清空 App.vue 文件内容
set "appVue=src\App.vue"

(
  echo ^<script setup^>^</script^>
  echo ^<template^>
  echo   ^<div class="navbar navbar-expand-lg"^
  echo        style="background: linear-gradient(to right, #ff69b4, #00ff00)"^>
  echo     ^<div class="container"^>
  echo       ^<img src="https://v5.bootcss.com/docs/5.3/assets/img/guides/bootstrap-vite.png" alt="Bootstrap Logo" class="mb-4" /^>
  echo       ^<h1 class="display-4"^>HELLO bootstrap^</h1^>
  echo     ^</div^>
  echo   ^</div^>
  echo ^</template^>
  echo ^<style^>^</style^>
) > "!appVue!"




REM 追加内容到 src/main.js 文件
set "mainJs=src\main.js"
echo import 'bootstrap/scss/bootstrap.scss' >> "!mainJs!"
echo main.js 文件更新完成。


echo 文件清理完成。



 
 echo '--------------------------------------------------------'
echo [V]项目创建成功 开始运行！
cd "%projectName%"
call npm run dev

pause


) else (
  echo 用户选择不安装 Bootstrap UI 框架。
  echo '--------------------------------------------------------'
echo [V]项目创建成功 开始运行！
cd "%projectName%"
call npm run dev

pause

)





