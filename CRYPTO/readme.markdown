### 【利用方法】

zipファイルには下記2ファイルが含まれています。

```
2016/02/21  22:17           122,496 crypto.savf
2016/02/21  22:44             3,495 readme.txt
               2 個のファイル             125,991 バイト
```

オブジェクトの作成と利用方法についてはiMagazineの該当記事を参照ください。

### 【SAVFの内容】

ソースファイル QGPL/CRYPTO が保管されており、下記5メンバーが含まれています。

```
ﾒﾝﾊﾞｰ       ﾀｲﾌﾟ        ﾃｷｽﾄ
CRYPTO      RPGLE       Sample AES encrypt/decrypt ILE-RPG module
CRYPTOCLP   CLP         CL program for crypto
CRYPTOCMD   CMD         CRYPTO fromt-end command
CRYPTOPROT  RPGLE       Prototype for CRYPTO procedure
CRYPTOWRAP  RPGLE       Wrapper for CRYPTO procedure
```

### 【ソースの転送と復元】

下記手順の要領でソースファイル QGPL/CRYPTO の転送・復元を行います。

**○ IBM i 側での受信用オンライン保管ファイルの作成**

```
> CRTSAVF FILE(QGPL/CRYPTOSAVF)
   ライブラリー QGPL にファイル CRYPTOSAVF が作成された。
```

**○ PC(Windows 7)からIBM i へFTP転送**

```
C:\Users\User\Desktop>ftp xxx.xxx.xxx.xxx
xxx.xxx.xxx.xxx に接続しました。
220-FTP Server (user 'xxxxxxx@xxx.ibm.com')
220
ユーザー (xxx.xxx.xxx.xxx:(none)): ユーザーID
331-Password:
331
パスワード:パスワード
230-220-QTCP AT サーバー名.
230-ユーザーID LOGGED ON.
230
ftp> bi
200 REPRESENTATION TYPE IS BINARY IMAGE.
ftp> put crypto.savf qgpl/cryptosavf
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO MEMBER CRYPTOSAVF IN FILE CRYPTOSAVF IN LIBRARY QGPL.
226 File transfer completed successfully.
ftp: 122496 バイトが送信されました 0.19秒 655.06KB/秒。
ftp> quit
221 QUIT SUBCOMMAND RECEIVED.

C:\Users\User\Desktop>
```

**○ オンライン保管ファイルの内容確認**

```
> DSPSAVF FILE(QGPL/CRYPTOSAVF)

                         保管されたオブジェクトの表示

 保管されたライブラリー  . . :   QGPL

 オプションを入力して，実行キーを押してください。
   5= 表示

 OPT  ｵﾌﾞｼﾞｪｸﾄ     タイプ    属性        所有者        ｻｲｽﾞ (K)   データ
      CRYPTO      *FILE     PF          XXXXXXX             148  YES
```

**○ ソースの復元**

```
> RSTOBJ OBJ(*ALL) SAVLIB(QGPL) DEV(*SAVF) SAVF(QGPL/CRYPTOSAVF) RSTLIB(QTE
  MP)
  1 個のオブジェクトを QGPL から QTEMP へ復元した。
> WRKMBRPDM FILE(QTEMP/CRYPTO)

                           PDM を使用したメンバーの処理                XXXXXX

  ファイル . . . .   CRYPTO
    ライブラリー .     QTEMP                 位置指定  . . . . . .

  オプションを入力して，実行キーを押してください。
  2= 編集     3=ｺﾋﾟｰ     4= 削除     5= 表示      6= 印刷      7= 名前の変更
  8= 記述の表示    9= 保管    13=ﾃｷｽﾄ の変更     14=ｺﾝﾊﾟｲﾙ    15=ﾓｼﾞｭｰﾙ 作成 ...

 OPT  ﾒﾝﾊﾞｰ       ﾀｲﾌﾟ        ﾃｷｽﾄ
      CRYPTO      RPGLE       Sample AES encrypt/decrypt ILE-RPG module
      CRYPTOCLP   CLP         CL program for crypto
      CRYPTOCMD   CMD         CRYPTO fromt-end command
      CRYPTOPROT  RPGLE       Prototype for CRYPTO procedure
      CRYPTOWRAP  RPGLE       Wrapper for CRYPTO procedure
```

### 【特記事項】

当配布物および記事は、2016年1月現在の情報に基づいて作成されております。

この資料に含まれる情報は可能な限り正確を期しておりますが、日本アイ・ビー・エム株式会社による正式なレビューは受けておらず、当資料に記載された内容に関して日本アイ・ビー・エム株式会社および筆者が何ら保証をするものではありません。

したがって、この情報の利用またはこれらの技法の実施はひとえに使用者の責任においてなされるものであり、当資料の内容によって受けたいかなる被害に関しても一切の保証をするものではありませんのでご了承ください。

2016/2/21
