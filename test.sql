SELECT 'alter ' || DECODE(TT.OBJECT_TYPE,
                          'PACKAGE BODY',
                          'PACKAGE',
                          'TYPE BODY',
                          'TYPE',
                          OBJECT_TYPE) || ' ' || TT.OBJECT_NAME ||
       ' compile ' || DECODE(TT.OBJECT_TYPE,
                             'PACKAGE',
                             ' ',
                             'PACKAGE BODY',
                             'BODY',
                             'TYPE BODY',
                             'BODY') || ' ;' invalidPkg
  FROM USER_OBJECTS TT
 WHERE TT.STATUS = 'INVALID'
   AND TT.OBJECT_TYPE != 'JAVA CLASS';
