
�y���p���@�z

zip�t�@�C���ɂ͉��L2�t�@�C�����܂܂�Ă��܂��B

2016/02/21  22:17           122,496 crypto.savf
2016/02/21  22:44             3,495 readme.txt
               2 �̃t�@�C��             125,991 �o�C�g

�I�u�W�F�N�g�̍쐬�Ɨ��p���@�ɂ��Ă�iMagazine�̊Y���L�����Q�Ƃ��������B

�ySAVF�̓��e�z

�\�[�X�t�@�C�� QGPL/CRYPTO ���ۊǂ���Ă���A���L5�����o�[���܂܂�Ă��܂��B

���ް       ����        ÷��
CRYPTO      RPGLE       Sample AES encrypt/decrypt ILE-RPG module
CRYPTOCLP   CLP         CL program for crypto
CRYPTOCMD   CMD         CRYPTO fromt-end command
CRYPTOPROT  RPGLE       Prototype for CRYPTO procedure
CRYPTOWRAP  RPGLE       Wrapper for CRYPTO procedure


�y�\�[�X�̓]���ƕ����z

���L�菇�̗v�̂Ń\�[�X�t�@�C�� QGPL/CRYPTO �̓]���E�������s���܂��B

�� IBM i ���ł̎�M�p�I�����C���ۊǃt�@�C���̍쐬

> CRTSAVF FILE(QGPL/CRYPTOSAVF)
   ���C�u�����[ QGPL �Ƀt�@�C�� CRYPTOSAVF ���쐬���ꂽ�B

�� PC(Windows 7)����IBM i ��FTP�]��

C:\Users\User\Desktop>ftp xxx.xxx.xxx.xxx
xxx.xxx.xxx.xxx �ɐڑ����܂����B
220-FTP Server (user 'xxxxxxx@xxx.ibm.com')
220
���[�U�[ (xxx.xxx.xxx.xxx:(none)): ���[�U�[ID
331-Password:
331
�p�X���[�h:�p�X���[�h
230-220-QTCP AT �T�[�o�[��.
230-���[�U�[ID LOGGED ON.
230
ftp> bi
200 REPRESENTATION TYPE IS BINARY IMAGE.
ftp> put crypto.savf qgpl/cryptosavf
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO MEMBER CRYPTOSAVF IN FILE CRYPTOSAVF IN LIBRARY QGPL.
226 File transfer completed successfully.
ftp: 122496 �o�C�g�����M����܂��� 0.19�b 655.06KB/�b�B
ftp> quit
221 QUIT SUBCOMMAND RECEIVED.

C:\Users\User\Desktop>

�� �I�����C���ۊǃt�@�C���̓��e�m�F

> DSPSAVF FILE(QGPL/CRYPTOSAVF)

                         �ۊǂ��ꂽ�I�u�W�F�N�g�̕\��

 �ۊǂ��ꂽ���C�u�����[  . . :   QGPL

 �I�v�V��������͂��āC���s�L�[�������Ă��������B
   5= �\��

 OPT  ��޼ު��     �^�C�v    ����        ���L��        ���� (K)   �f�[�^
      CRYPTO      *FILE     PF          XXXXXXX             148  YES


�� �\�[�X�̕���

> RSTOBJ OBJ(*ALL) SAVLIB(QGPL) DEV(*SAVF) SAVF(QGPL/CRYPTOSAVF) RSTLIB(QTE
  MP)
  1 �̃I�u�W�F�N�g�� QGPL ���� QTEMP �֕��������B
> WRKMBRPDM FILE(QTEMP/CRYPTO)

                           PDM ���g�p���������o�[�̏���                XXXXXX

  �t�@�C�� . . . .   CRYPTO
    ���C�u�����[ .     QTEMP                 �ʒu�w��  . . . . . .

  �I�v�V��������͂��āC���s�L�[�������Ă��������B
  2= �ҏW     3=��߰     4= �폜     5= �\��      6= ���      7= ���O�̕ύX
  8= �L�q�̕\��    9= �ۊ�    13=÷�� �̕ύX     14=���߲�    15=Ӽޭ�� �쐬 ...

 OPT  ���ް       ����        ÷��
      CRYPTO      RPGLE       Sample AES encrypt/decrypt ILE-RPG module
      CRYPTOCLP   CLP         CL program for crypto
      CRYPTOCMD   CMD         CRYPTO fromt-end command
      CRYPTOPROT  RPGLE       Prototype for CRYPTO procedure
      CRYPTOWRAP  RPGLE       Wrapper for CRYPTO procedure


�y���L�����z

���z�z������ыL���́A2016�N1�����݂̏��Ɋ�Â��č쐬����Ă���܂��B���̎����Ɋ܂܂����͉\�Ȍ��萳�m��
�����Ă���܂����A���{�A�C�E�r�[�E�G��������Ђɂ�鐳���ȃ��r���[�͎󂯂Ă��炸�A�������ɋL�ڂ��ꂽ���e�Ɋւ���
���{�A�C�E�r�[�E�G��������Ђ���ѕM�҂�����ۏ؂�������̂ł͂���܂���B
���������āA���̏��̗��p�܂��͂����̋Z�@�̎��{�͂ЂƂ��Ɏg�p�҂̐ӔC�ɂ����ĂȂ������̂ł���A
�������̓��e�ɂ���Ď󂯂������Ȃ��Q�Ɋւ��Ă���؂̕ۏ؂�������̂ł͂���܂���̂ł��������������B

2016/2/21
