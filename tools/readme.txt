1、加密资源（目前暂不加密，已经验证可以加密，但是改动会有点不协调，等待后续版本调整）
2、加密脚本
3、针对加密后的资源和脚本，生成flist（未加密的）
4、从未加密的updater中打包updater.zip（这个已经被加密了）
5、上传服务器

上传文件命令：
pscp.exe -r ..\encode root@120.24.75.91:/alidata/www/default/zwsatan