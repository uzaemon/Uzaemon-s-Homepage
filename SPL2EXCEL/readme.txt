
�y���p���@�z

1. SPL2EXCEL.xlsm ����� pgms.savf ��C�ӂ̃f�B���N�g���[�ɉ𓀂��܂��B
   ����2�̃t�@�C���͓����f�B���N�g���[�ɒu���܂��B
2. SPL2EXCEL.xlsm ���N�����A�K�v�ȏ�����͂���Alt+F8�Ń}�N���umain�v���N�����܂��B

�ySAVF�̓��e�z

SAVF����т���Ɋ܂܂��v���O������TGTRLS(V5R4M0)�ō쐬���Ă���܂��B

 OPT  ��޼ު��     �^�C�v    ����        ���L��        ���� (K)   �f�[�^
      SHIFT       *PGM      RPGLE       QPGMR               124  YES
      SPL2TXT     *PGM      CLP         QPGMR                48  YES

�yIBM i �̃\�[�X�ƃR���p�C���z

V5R4���Â�AS/400�Ńe�X�g�ł���悤�ɁA�\�[�X��PC�e�L�X�g�`���Ŕz�z���܂��B

�C�ӂ̃\�[�X�t�@�C�����쐬���A�𓀂��� shift.rpgle.txt (IL-RPG)�����
spl2txt.rpgle.txt (CL�v���O����)��FTP�ȂǂŃ\�[�X�t�@�C���Ƀe�L�X�g���[�h�œ]�����܂��B

pgms.savf �Ɠ��l�̓��e�ɂ���ɂ͏�L�v���O������QTEMP�ɍ쐬���A�C�ӂ̃��C�u�����[��
PGMS�Ƃ���SAVF���쐬����QTEMP�̃v���O������ۊǂ��ASAVF��PC�Ƀo�C�i���\���[�h�œ]�����܂��B

> CRTBNDRPG PGM(QTEMP/SHIFT) SRCFILE(�\�[�X�t�@�C��) DFTACTGRP(*NO) TGTRLS(V5R
  4M0)
   �v���O���� SHIFT �����C�u�����[ QTEMP �ɓ�����܂����B�ō��̏d��x��
    00 �B 15/04/XX �� 19:50:07 �ɍ쐬����܂����B
> CRTCLPGM PGM(QTEMP/SPL2TXT) SRCFILE(�\�[�X�t�@�C��) TGTRLS(V5R4M0)
   �v���O���� SPL2TXT �����C�u�����[ QTEMP �ɍ쐬���ꂽ�B
> CRTSAVF FILE(���C�u�����[��/PGMS)
   ���C�u�����[ XXXXXXXXXX �Ƀt�@�C�� PGMS ���쐬���ꂽ�B
> SAVOBJ OBJ(*ALL) LIB(QTEMP) DEV(*SAVF) OBJTYPE(*PGM) SAVF(���C�u�����[��/PGMS) TGTR
  LS(V5R4M0) DTACPR(*MEDIUM)
  2 �̃I�u�W�F�N�g�����C�u�����[ QTEMP ����ۊǂ���܂����B 0 �̃I�u�W
     �F�N�g���g�ݍ��܂�Ă��܂���B

�y���L�����z

���z�z������ыL���́A2015�N4�����݂̏��Ɋ�Â��č쐬����Ă���܂��B���̎����Ɋ܂܂����͉\�Ȍ��萳�m��
�����Ă���܂����A���{�A�C�E�r�[�E�G��������Ђɂ�鐳���ȃ��r���[�͎󂯂Ă��炸�A�������ɋL�ڂ��ꂽ���e�Ɋւ���
���{�A�C�E�r�[�E�G��������Ђ���ѕM�҂�����ۏ؂�������̂ł͂���܂���B
���������āA���̏��̗��p�܂��͂����̋Z�@�̎��{�͂ЂƂ��Ɏg�p�҂̐ӔC�ɂ����ĂȂ������̂ł���A
�������̓��e�ɂ���Ď󂯂������Ȃ��Q�Ɋւ��Ă���؂̕ۏ؂�������̂ł͂���܂���̂ł��������������B

2015/4/17
