### 【利用方法】

1. SPL2EXCEL.xlsm および pgms.savf を任意のディレクトリーに解凍します。この2つのファイルは同じディレクトリーに置きます。
1. SPL2EXCEL.xlsm を起動し、必要な情報を入力してAlt+F8でマクロ「main」を起動します。

### 【SAVFの内容】

SAVFおよびこれに含まれるプログラムはTGTRLS(V5R4M0)で作成してあります。

```
 OPT  ｵﾌﾞｼﾞｪｸﾄ     タイプ    属性        所有者        ｻｲｽﾞ (K)   データ
      SHIFT       *PGM      RPGLE       QPGMR               124  YES
      SPL2TXT     *PGM      CLP         QPGMR                48  YES
```

### 【IBM i のソースとコンパイル】

V5R4より古いAS/400でテストできるように、ソースはPCテキスト形式で配布します。

任意のソースファイルを作成し、解凍した shift.rpgle.txt (IL-RPG)およびspl2txt.rpgle.txt (CLプログラム)をFTPなどでソースファイルにテキストモードで転送します。

pgms.savf と同様の内容にするには上記プログラムをQTEMPに作成し、任意のライブラリーにPGMSというSAVFを作成してQTEMPのプログラムを保管し、SAVFをPCにバイナリ―モードで転送します。

```
> CRTBNDRPG PGM(QTEMP/SHIFT) SRCFILE(ソースファイル) DFTACTGRP(*NO) TGTRLS(V5R
  4M0)
   プログラム SHIFT がライブラリー QTEMP に入れられました。最高の重大度は
    00 。 15/04/XX の 19:50:07 に作成されました。
> CRTCLPGM PGM(QTEMP/SPL2TXT) SRCFILE(ソースファイル) TGTRLS(V5R4M0)
   プログラム SPL2TXT がライブラリー QTEMP に作成された。
> CRTSAVF FILE(ライブラリー名/PGMS)
   ライブラリー XXXXXXXXXX にファイル PGMS が作成された。
> SAVOBJ OBJ(*ALL) LIB(QTEMP) DEV(*SAVF) OBJTYPE(*PGM) SAVF(ライブラリー名/PGMS) TGTR
  LS(V5R4M0) DTACPR(*MEDIUM)
  2 個のオブジェクトがライブラリー QTEMP から保管されました。 0 個のオブジ
     ェクトが組み込まれていません。

```

### 【特記事項】

当配布物および記事は、2016年1月現在の情報に基づいて作成されております。

この資料に含まれる情報は可能な限り正確を期しておりますが、日本アイ・ビー・エム株式会社による正式なレビューは受けておらず、当資料に記載された内容に関して日本アイ・ビー・エム株式会社および筆者が何ら保証をするものではありません。

したがって、この情報の利用またはこれらの技法の実施はひとえに使用者の責任においてなされるものであり、当資料の内容によって受けたいかなる被害に関しても一切の保証をするものではありませんのでご了承ください。

2015/4/17
