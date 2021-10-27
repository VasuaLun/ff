create or replace package body APKG_XLSREP is

  ---------------------------------------------------- Общие данные ------------------------------------------------------

  nREPORTTYPE            number(1);                 -- Тип отчета ( 0 - XLSXML, 1 - XLSX )

  type tXLSROWS  is table of A_XLSROWS%rowtype index by pls_integer;
  vXLSROWS               tXLSROWS;

  type tXLSCELLS is table of A_XLSCELLS%rowtype index by pls_integer;
  vXLSCELLS              tXLSCELLS;

  type tNAMES is table of varchar2(240);
  rSHEETNAMES            tNAMES;

  -- номер последнего столбца в строке
  type tNUMCOL is table of number index by pls_integer;
  rNUMCOL                tNUMCOL;

  -- индекс ячейки в vXLSCELLS
  type tINDEX_XLSCELLS is table of number index by varchar2( 50 );
  rINDEX_XLSCELLS        tINDEX_XLSCELLS;

  sVERSION               constant varchar2(1000) := '27.04.2016';     -- Текущая версия
  sXMLHEAD               varchar2(240);

  iCHARSETID             integer;

  -------------------------------------------------------- XLSX ----------------------------------------------------------

  type tFILES is table of clob index by varchar2(240);
  rFILES                 tFILES;
  rCONDFORMAT            tFILES;
  /*НОВЫЙ ФУНКЦИОНАЛ: добавление картинки "Печать с подписью" для Минздрав Сахалин. GALA*/
  type tDRAWINGS is table of blob index by varchar2(240);
  rDRAWINGS                tDRAWINGS;
  /*----------------окончание--------------------*/

  type tSHAREDSTRINGS is table of number index by varchar2(4000);
  rSHAREDSTRINGS         tSHAREDSTRINGS;

  type tIDS is table of number(17) index by varchar2(240);
  rSTYLEIDS              tIDS;

  cST_NUMFMTS            clob;
  cST_FONTS              clob;
  cST_FILLS              clob;
  cST_BORDERS            clob;
  cST_CELLSTYLEXFS       clob;
  cST_CELLXFS            clob;
  cST_CELLSTYLES         clob;
  cWS_STATICCELLS        clob;
  сST_RUNTITLE           clob;
  cST_CONDFORMAT         clob;
  CST_DXFS               clob;

  iSHEETID               integer;
  iSTRINGID              integer;
  iSTYLEID               integer;
  iCOLUMNID              integer;
  lCOLSOPEN              boolean        := false;   -- Признак открытого региона колонок
  iDXFS                  integer;

  nPROTECTED             number(1);                 -- Защищенный лист
  sPASSWORD              varchar2(255);             -- Пароль для снятия защиты листа
  sORIENTATION           varchar2(20);              -- Ориентация листа

  ------------------------------------------------------- XLS-XML --------------------------------------------------------

  lSTYLESOPEN            boolean        := false;   -- Признак открытого региона стилей
  lNAMESOPEN             boolean        := false;   -- Признак открытого региона именованных ячеек
  lPAGEBREAKSOPEN        boolean        := false;   -- Признак открытого региона разрывов страниц
  lOPTIMIZE_INSERT       boolean        := false;   -- Оптимизация добаления ячеек в буфер. Делается в момент flush
                                                    -- Актуально для большого объёма данных
                                                    -- Отключается возможность данимического исправления ячеек в таблице

  cCLOB                  clob;                      -- Текст отчета

  iDRAWING                 number         := 0;
  nCURCELL_RN            number         := 0;       -- RN Текущей ячейки
  nCURRENTSTATE          number         := 0;       -- Текущее состояние
  nINDENT                number(3);                 -- Отступ. Задается при создании БЛОБа. Контролируется автоматически.
  nlHSTATICCELLS         number         := 0;       -- Количество заголовочных ячеек
  nlVSTATICCELLS         number         := 0;       -- Количество неподвижных ячеек слева

  nROWCOUNT              number(17)     := 0;       -- Количество строк во временной таблице на данный момент и номер текущей строки
  slDATA                 varchar2(4000) := '';      -- Данные о листе

  nAUTOFILTERX           number;                    -- Флаг применения автофильтра по горизонтали
  nAUTOFILTERX_R1        number;                    -- Автофильтр X - первый ряд
  nAUTOFILTERX_R2        number;                    -- Автофильтр X - последний ряд
  nAUTOFILTERX_C1        number;                    -- Автофильтр Х - первая колонка
  nAUTOFILTERX_C2        number;                    -- Автофильтр Х - последняя колонка

  sCELL_CONDFORMAT       clob;                      -- ячейки условного форматирования
  nPRIORITY              integer := 1;              -- приоритет условного форматирования
  sCURRENTRELSHEET         varchar2(255);

  -----------------------------------------------------------------------------------------------------------------------
  -- Процедура выставляет контекст аналогично его первой инициализации
  procedure SET_DEFAULT_VARS
  is
  begin
    lCOLSOPEN            := false;
    lSTYLESOPEN          := false;
    lNAMESOPEN           := false;
    lPAGEBREAKSOPEN      := false;
    lOPTIMIZE_INSERT     := false;
    nCURRENTSTATE        := 0;
    nlHSTATICCELLS       := 0;
    nlVSTATICCELLS       := 0;
    nROWCOUNT            := 0;
    slDATA               := '';
  end;

  -- 0   - не строится,
  -- 10  - только что создан,
  -- 20  - добавление стилей (необязательно),
  -- 30  - лист создан,
  -- 40  - создание именованных регионов (необязательно)
  -- 50  - открыта таблица с данными, колонки не объявлены,
  -- 60  - объявление колонок,
  -- 70  - создана хотя бы одна строка, можно добавлять строки и ячейки в текущую строку
  -- 80  - произведена выгрузка строк,
  -- 90  - закрыта страница,
  -- 100 - закрыт лист, можно закрыть докумнет или создать новый
  -- 200 - построение завершено
  function DECODE_STATE
  (
    nSTATE               in number
  )
  return varchar2
  is
  begin
    return case nSTATE
             when 0   then 'Не строится'
             when 10  then 'Открыт на редактирование'
             when 20  then 'Добавление стилей'
             when 30  then 'Лист создан'
             when 40  then 'Создание именованных регионов (необязательно)'
             when 50  then 'Открыта таблица с данными, колонки не объявлены'
             when 60  then 'Объявление колонок'
             when 70  then 'Создана хотя бы одна строка, можно добавлять строки и ячейки в текущую строку'
             when 80  then 'Произведена выгрузка строк'
             when 90  then 'Закрыта страница'
             when 100 then 'Открыт на редактирование, лист завершен'
             when 200 then 'Построение завершено'
           end;
  end;

  -- функция осуществляет циклический сдвиг 15-разрядного числа на N влево
  function F_ROTATE
  (
    nNUM            in number, -- число
    nN              in number  -- на сколько двигать
  )return integer
  as
    sBIT15          varchar2(1);
    sBIT1_14        varchar2(14);
    sNUM            varchar2(15);
    nRES            integer;
  begin
    sNUM := '';
    for j in 1..15
    loop
      if ( bitand( nNUM, power( 2, j-1 ) ) = power( 2, j-1 ) ) then
        sNUM := '1'||sNUM;
      else
        sNUM := '0'||sNUM;
      end if;
    end loop;

    for i in 1..nN
    loop
      sBIT15 := substr( sNUM, 1, 1);
      sBIT1_14 := substr( sNUM, 2, 14);
      sNUM := sBIT1_14||sBIT15;
    end loop;

    nRES := 0;
    for k in 1..15
    loop
      if ( substr( sNUM, k, 1 ) = '1' ) then
        nRES := nRES + power( 2, 15-k );
      end if;
    end loop;

    return nRES;
  end;

  /* вычисление хэша */
  --http://chicago.sourceforge.net/devel/docs/excel/encrypt.html
  function GET_HASH
  (
    sPASSWORD           in varchar2
  )
  return varchar2
  as
    sHASH               varchar2(8);

  begin
    if sPASSWORD is not null then
      for i in 2 .. length(sPASSWORD)
      loop
        if sHASH is not null then
          sHASH := UTL_RAW.BIT_XOR( sHASH, UTL_RAW.cast_from_binary_integer( F_ROTATE(ASCII(substr(sPASSWORD, i, 1)), i)));
        else
          sHASH := UTL_RAW.BIT_XOR( UTL_RAW.cast_from_binary_integer(F_ROTATE(ASCII(substr(sPASSWORD, i-1, 1)), i-1)), UTL_RAW.cast_from_binary_integer(F_ROTATE(ASCII(substr(sPASSWORD, i, 1)), i)));
        end if;
      end loop;

      sHASH := UTL_RAW.BIT_XOR( sHASH, UTL_RAW.cast_from_binary_integer(length(sPASSWORD)));

      sHASH := RAWTOHEX(UTL_RAW.BIT_XOR( sHASH, UTL_RAW.cast_from_binary_integer(52811)));
      return substr(sHASH, 5, 4);
    else
      return '';
    end if;
  end;


  /* проверка имени листа */
  function CHECK_SHEET_NAME
  (
    sSHEET_NAME         in varchar2     -- Название листа
  )
  return varchar2
  as
    sSHNAME             varchar2(200);  -- Название листа
  begin
    if sSHEET_NAME is null then
      AP_EXCEPTION( 0, 'Не задано имя листа!' );
    end if;

    sSHNAME := sSHEET_NAME;

    if length( sSHNAME ) > 30 then
      sSHNAME := substr( sSHNAME, 1, 30 );
    end if;

    sSHNAME := translate( sSHNAME, ':?/\*[]', ' ' );
    return( sSHNAME );
  end CHECK_SHEET_NAME;

  function SP_CHAR_REPL     --Экранирование спецсимволов
  (
    sINVALUE            in varchar2
  ) return varchar2
  is
    sOUTVALUE           varchar2(32767);
  begin
    sOUTVALUE := replace(sINVALUE, '&', '&amp;');
    sOUTVALUE := replace(sOUTVALUE, '<', '&lt;');
    sOUTVALUE := replace(sOUTVALUE, '>', '&gt;');
    sOUTVALUE := replace(sOUTVALUE, '"', '&quot;');
    sOUTVALUE := replace(sOUTVALUE, chr(13));
    sOUTVALUE := replace(sOUTVALUE, chr(10), '&#10;');

    return sOUTVALUE;
  end;

  function ZIP_BYTE_CAST
  (
    p_big in number,
    p_bytes in pls_integer := 4
  ) return raw
  is
  begin
    return utl_raw.substr
                  ( utl_raw.cast_from_binary_integer( p_big
                                                    , utl_raw.little_endian
                                                    )
                  , 1
                  , p_bytes
                  );
  end;

  procedure ZIP_ADD_FILE(
    p_zipped_blob in out blob
  , p_name in varchar2
  , p_content in blob
  )
  is
    t_now date;
    t_blob blob;
    t_clen integer;
  begin
    t_now := sysdate;
    t_blob := utl_compress.lz_compress( p_content );
    t_clen := dbms_lob.getlength( t_blob );
    if p_zipped_blob is null
    then
      dbms_lob.createtemporary( p_zipped_blob
                              , true
                              );
    end if;
    dbms_lob.append
      ( p_zipped_blob
      , utl_raw.concat
          ( hextoraw( '504B0304' )              -- Local file header signature
          , hextoraw( '1400' )                  -- version 2.0
          , hextoraw( '0000' )                  -- no General purpose bits
          , hextoraw( '0800' )                  -- deflate
          , ZIP_BYTE_CAST
              (   to_number( to_char( t_now
                                    , 'ss'
                                    ) ) / 2
                + to_number( to_char( t_now
                                    , 'mi'
                                    ) ) * 32
                + to_number( to_char( t_now
                                    , 'hh24'
                                    ) ) * 2048
              , 2
              )                                 -- File last modification time
          , ZIP_BYTE_CAST
              (   to_number( to_char( t_now
                                    , 'dd'
                                    ) )
                + to_number( to_char( t_now
                                    , 'mm'
                                    ) ) * 32
                + ( to_number( to_char( t_now
                                      , 'yyyy'
                                      ) ) - 1980 ) * 512
              , 2
              )                                 -- File last modification date
          , dbms_lob.substr( t_blob
                           , 4
                           , t_clen - 7
                           )                                         -- CRC-32
          , ZIP_BYTE_CAST( t_clen - 18 )                    -- compressed size
          , ZIP_BYTE_CAST( dbms_lob.getlength( p_content ) )
                                                          -- uncompressed size
          , ZIP_BYTE_CAST( length( p_name )
                         , 2
                         )                                 -- File name length
          , hextoraw( '0000' )                           -- Extra field length
          , utl_raw.cast_to_raw( p_name )                         -- File name
          )
      );
    dbms_lob.copy( p_zipped_blob
                 , t_blob
                 , t_clen - 18
                 , dbms_lob.getlength( p_zipped_blob ) + 1
                 , 11
                 );                                      -- compressed content
    dbms_lob.freetemporary( t_blob );
  end;
--
  procedure ZIP_FINISH(
    p_zipped_blob in out blob
  )
  is
    t_cnt pls_integer := 0;
    t_offs integer;
    t_offs_dir_header integer;
    t_offs_end_header integer;
    t_comment raw( 32767 )
                 := utl_raw.cast_to_raw( 'Implementation by Anton Scheffer' );
  begin
    t_offs_dir_header := dbms_lob.getlength( p_zipped_blob );
    t_offs := dbms_lob.instr( p_zipped_blob
                            , hextoraw( '504B0304' )
                            , 1
                            );
    while t_offs > 0
    loop
      t_cnt := t_cnt + 1;
      dbms_lob.append
        ( p_zipped_blob
        , utl_raw.concat
            ( hextoraw( '504B0102' )
                                    -- Central directory file header signature
            , hextoraw( '1400' )                                -- version 2.0
            , dbms_lob.substr( p_zipped_blob
                             , 26
                             , t_offs + 4
                             )
            , hextoraw( '0000' )                        -- File comment length
            , hextoraw( '0000' )              -- Disk number where file starts
            , hextoraw( '0100' )                   -- Internal file attributes
            , hextoraw( '2000B681' )               -- External file attributes
            , ZIP_BYTE_CAST( t_offs - 1 )
                                       -- Relative offset of local file header
            , dbms_lob.substr
                ( p_zipped_blob
                , utl_raw.cast_to_binary_integer
                                           ( dbms_lob.substr( p_zipped_blob
                                                            , 2
                                                            , t_offs + 26
                                                            )
                                           , utl_raw.little_endian
                                           )
                , t_offs + 30
                )                                                 -- File name
            )
        );
      t_offs :=
          dbms_lob.instr( p_zipped_blob
                        , hextoraw( '504B0304' )
                        , t_offs + 32
                        );
    end loop;
    t_offs_end_header := dbms_lob.getlength( p_zipped_blob );
    dbms_lob.append
      ( p_zipped_blob
      , utl_raw.concat
          ( hextoraw( '504B0506' )       -- End of central directory signature
          , hextoraw( '0000' )                          -- Number of this disk
          , hextoraw( '0000' )          -- Disk where central directory starts
          , ZIP_BYTE_CAST
                   ( t_cnt
                   , 2
                   )       -- Number of central directory records on this disk
          , ZIP_BYTE_CAST( t_cnt
                         , 2
                         )        -- Total number of central directory records
          , ZIP_BYTE_CAST( t_offs_end_header - t_offs_dir_header )
                                                  -- Size of central directory
          , ZIP_BYTE_CAST
                    ( t_offs_dir_header )
                                       -- Relative offset of local file header
          , ZIP_BYTE_CAST
                ( nvl( utl_raw.length( t_comment )
                     , 0
                     )
                , 2
                )                                   -- ZIP file comment length
          , t_comment
          )
      );
  end;

  -- Добавление строки в файл-буфер (XLS-XML)
  procedure PUT_LINE
  (
    sVALUE          in varchar2
  )
  is
    sCLOBVALUE      varchar2( 32767 );
  begin
    --sCLOBVALUE := lpad(' ', nINDENT*nINDENTSPACES) || sVALUE || sCR;
    sCLOBVALUE := sVALUE || sCR;
    DBMS_LOB.writeappend( cCLOB, length(sCLOBVALUE), sCLOBVALUE );
  end;

  -- Добавление строки в файл-буфер (XLSX)
  procedure PUT_LINE
  (
    sFILE           in varchar2,
    sVALUE          in varchar2
  )
  is
    sCLOBVALUE      varchar2( 32767 );
  begin
    sCLOBVALUE := sVALUE || sCR;
    DBMS_LOB.writeappend( rFILES( sFILE ), length( sCLOBVALUE ), sCLOBVALUE );
  end;

  /*НОВЫЙ ФУНКЦИОНАЛ: добавление картинки "Печать с подписью" для Минздрав Сахалин. GALA*/
  procedure ADD_DRAWING_BLOB
  (
    sFILE           in varchar2,
    bVALUE          in BLOB
  )
  is
  begin
    rDRAWINGS( sFILE ) := bVALUE;
  end;
  /*------------окончание--------------------*/

  -- Устанавливает переменные для автофильтра
  procedure SET_AUTOFILTERX
  (
    nR1                  number,
    nR2                  number,
    nC1                  number,
    nC2                  number
  )
  is
  begin
    nAUTOFILTERX := 1;
    nAUTOFILTERX_R1 := nR1;
    nAUTOFILTERX_R2 := nR2;
    nAUTOFILTERX_C1 := nC1;
    nAUTOFILTERX_C2 := nC2;
  end;

  function GET_VERSION return varchar2
  is
  begin
    return sVERSION;
  end;

  -- Возвращает имя колонки в RefMode "A1" по ее индексу
  function GET_COL_NAME
  (
    nINDEX               in number
  )
  return varchar2
  is
    sRESULT              varchar2(20);
    nDIV                 integer;
    nMOD                 integer;
  begin
    nDIV := nINDEX;

    while nDIV > 0
    loop
        nMOD := mod( ( nDIV - 1 ), 26 );
        sRESULT := CHR( ( 65 + nMOD ) ) || sRESULT;
        nDIV := trunc( ( nDIV - nMOD) / 26 );
    end loop;

    return sRESULT;
  end;

  -- вычислить номер последнего добавленного столбца в строке
  function                     GET_COLNUMBER_LAST
  (
    nROWNUMB                   in number
  )
  return                       number
  as
    i                          pls_integer := 0;
    nCOLNUMB                   number;
  begin
    if lOPTIMIZE_INSERT then
      if rNUMCOL.EXISTS( nROWNUMB ) then
        nCOLNUMB := rNUMCOL( nROWNUMB );
      else
        ap_exception( 0, 'Отсутствует строка с номером %s', nROWNUMB );
      end if;
    else
      begin
        select c.COLNUMB + c.MERGEACROSS
          into nCOLNUMB
          from A_XLSCELLS c
         where c.PRN = nROWNUMB
           and c.COLNUMB = (
                             select max( c1.COLNUMB )
                               from A_XLSCELLS c1
                              where c1.PRN = nROWNUMB
                           );
      exception
        when no_data_found then
          nCOLNUMB := null;
      end;
    end if;

    return nvl( nCOLNUMB, 0 );
  end;

  -- Возвращает индекс колонки в RefMode "A1" по ее имени
  function GET_COL_INDEX
  (
    sNAME                in varchar2
  )
  return varchar2
  is
    sBUFFER              varchar2(20);
    sLETTER              varchar2(1);
    nPOW                 integer;
    nRESULT              integer;
  begin
    sBUFFER := sNAME;
    nRESULT := 0;
    nPOW := 1;
    while length( sBUFFER ) > 0
    loop
      sLETTER := substr( sBUFFER, length( sBUFFER ) );
      sBUFFER := substr( sBUFFER, 1, length( sBUFFER ) - 1 );
      nRESULT := nRESULT + ( ASCII( sLETTER ) - 64 ) * nPOW;
      nPOW := nPOW * 26;
    end loop;

    return nRESULT;
  end;

  /*def index_to_int(index):
  s = 0
  pow = 1
  for letter in index[::-1]:
      d = int(letter,36) - 9
      s += pow * d
      pow *= 26
  # excel starts column numeration from 1
  return s*/

  function GET_CUR_ROW return number -- Возвращает номер текущей строки
  is
  begin
    return nROWCOUNT;
  end;

  -- Возвращает количество ячеек в строке (оставлено как старый функционал). !!! Не проверено, возможны ошибки
  function GET_CUR_CELL
  (
    nROWNUMBER                 in number := 0 -- Номер строки
  ) return number
  is
    nROW                       number := case when nROWNUMBER = 0 then nROWCOUNT else nROWNUMBER end;
    nCURCELL_COL               number;
    i                          pls_integer := 0;
  begin
    if lOPTIMIZE_INSERT then
      nCURCELL_COL := 0;

      -- Бежим по коллекции
      i := vXLSCELLS.first;
      while i is not null
      loop
        if vXLSCELLS(i).PRN = nROW then
          nCURCELL_COL := nCURCELL_COL + 1;
        end if;
        i := vXLSCELLS.next(i);
      end loop;
    else
      select count(*)
        into nCURCELL_COL
        from A_XLSCELLS c
       where c.PRN = nROW;
    end if;

    return nCURCELL_COL;
  end;

  -- Возвращает RN последней ячейки
  function GET_CUR_CELL_RN return number
  is
  begin
    return nCURCELL_RN;
  end;

  -- проверка наличия строки
  function EXISTS_ROW
  (
    nROW                   in number
  )
  return                   number
  as
    i                      pls_integer := 0;
    nEXISTS                number(1) := 0;
  begin
    if lOPTIMIZE_INSERT then
      -- Бежим по коллекции
      i := vXLSROWS.first;
      while i is not null
      loop
        if vXLSROWS(i).RN = nROW then
          nEXISTS := 1;
          exit;
        end if;
        i := vXLSROWS.next(i);
      end loop;

    else
      select count(*)
        into nEXISTS
        from A_XLSROWS r
       where r.RN = nROW;
    end if;

    return nEXISTS;
  end;

  -- проверка наличия ячейки по номеру столбца и строки
  function EXISTS_CELL
  (
    nROW                   in number,
    nCOL                   in number
  )
  return                   number
  as
    i                      pls_integer := 0;
    nEXISTS                number(1) := 0;
  begin
    if lOPTIMIZE_INSERT then
      -- если номер последнего столбца в строке не меньше номер колонки
      if rNUMCOL( nROW ) >= nCOL then
        nEXISTS := 1;
      end if;
    else
      select count(*)
        into nEXISTS
        from A_XLSCELLS c
       where c.PRN = nROW
         and c.COLNUMB = nCOL;
    end if;

    return nEXISTS;
  end;

  procedure FREE_BLOB
  is
    sFILENAME                  varchar2(240);
  begin
    if сST_RUNTITLE is not null then
      DBMS_LOB.FREETEMPORARY( сST_RUNTITLE );
    end if;

    if cST_CONDFORMAT is not null then
      DBMS_LOB.FREETEMPORARY( cST_CONDFORMAT );
    end if;

    rCONDFORMAT.DELETE;
    -- XLS-XML
    if nREPORTTYPE = 0 then
      if cCLOB is not null then
        DBMS_LOB.FREETEMPORARY(cCLOB);
        cCLOB := null;
      end if;

    -- XLSX
    elsif nREPORTTYPE = 1 then
      sFILENAME := rFILES.first;

      while sFILENAME is not null
      loop
        DBMS_LOB.FREETEMPORARY( rFILES( sFILENAME ) );
        sFILENAME := rFILES.next( sFILENAME );
      end loop;
      rFILES.delete;

      rSHAREDSTRINGS.delete;
      rSTYLEIDS.delete;

      if cST_NUMFMTS is not null then
        DBMS_LOB.FREETEMPORARY( cST_NUMFMTS );
      end if;
      if cST_FONTS is not null then
        DBMS_LOB.FREETEMPORARY( cST_FONTS );
      end if;
      if cST_FILLS is not null then
        DBMS_LOB.FREETEMPORARY( cST_FILLS );
      end if;
      if cST_BORDERS is not null then
        DBMS_LOB.FREETEMPORARY( cST_BORDERS );
      end if;
      if cST_CELLSTYLEXFS is not null then
        DBMS_LOB.FREETEMPORARY( cST_CELLSTYLEXFS );
      end if;
      if cST_CELLSTYLEXFS is not null then
        DBMS_LOB.FREETEMPORARY( cST_DXFS );
      end if;
      if cST_CELLXFS is not null then
        DBMS_LOB.FREETEMPORARY( cST_CELLXFS );
      end if;
      if cST_CELLSTYLES is not null then
        DBMS_LOB.FREETEMPORARY( cST_CELLSTYLES );
      end if;
      if cWS_STATICCELLS is not null then
        DBMS_LOB.FREETEMPORARY( cWS_STATICCELLS );
      end if;
    end if;
  end;

  function GET_CLOB return clob
  is
  begin
    return cCLOB;
  end GET_CLOB;


  function GET_BLOB
  return blob
  is
    bRESULT           blob;
    bCONTENT          blob;
    bCONTENT2          blob;
    sFILENAME         varchar2(240);

    nDEST_OFFSET      integer := 1;
    nSOURCE_OFFSET    integer := 1;
    nLANG_CONTEXT     integer := DBMS_LOB.DEFAULT_LANG_CTX;
    nWARNING          integer := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
  begin
    DBMS_LOB.CREATETEMPORARY(bRESULT, true);

    if nCURRENTSTATE != 200 then
      AP_EXCEPTION( 0, 'Печать отчета невозможна, так как его построение не было корректно завершено. Последнее состояние отчета - "%s"',
                      DECODE_STATE( nCURRENTSTATE ) );
    end if;

    if сST_RUNTITLE is not null then
      DBMS_LOB.FREETEMPORARY( сST_RUNTITLE );
    end if;

    if cST_CONDFORMAT is not null then
      DBMS_LOB.FREETEMPORARY( cST_CONDFORMAT );
    end if;

    rCONDFORMAT.DELETE;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      DBMS_LOB.CONVERTTOBLOB(bRESULT, cCLOB, DBMS_LOB.LOBMAXSIZE, nDEST_OFFSET, nSOURCE_OFFSET, iCHARSETID, nLANG_CONTEXT, nWARNING);

      if cCLOB is not null then
        DBMS_LOB.FREETEMPORARY(cCLOB);
        cCLOB := null;
      end if;

    -- XLSX
    elsif nREPORTTYPE = 1 then
      DBMS_LOB.CREATETEMPORARY(bCONTENT, true);


      sFILENAME := rFILES.first;

      while sFILENAME is not null
      loop
        DBMS_LOB.trim( bCONTENT, 0 );
        nDEST_OFFSET   := 1;
        nSOURCE_OFFSET := 1;
        DBMS_LOB.CONVERTTOBLOB( bCONTENT, rFILES( sFILENAME ), DBMS_LOB.LOBMAXSIZE, nDEST_OFFSET, nSOURCE_OFFSET, iCHARSETID, nLANG_CONTEXT, nWARNING );
        DBMS_LOB.FREETEMPORARY( rFILES( sFILENAME ) );

        ZIP_ADD_FILE( bRESULT, sFILENAME, bCONTENT );
        sFILENAME := rFILES.next( sFILENAME );
      end loop;

      /*НОВЫЙ ФУНКЦИОНАЛ: добавление картинки "Печать с подписью" для Минздрав Сахалин. GALA*/
      sFILENAME := rDRAWINGS.first;

      while sFILENAME is not null
      loop
        ZIP_ADD_FILE( bRESULT, sFILENAME, rDRAWINGS(sFILENAME) );
        sFILENAME := rDRAWINGS.next( sFILENAME );
      end loop;
      /*----------------окончание--------------------*/

      ZIP_FINISH( bRESULT );

      DBMS_LOB.FREETEMPORARY( bCONTENT );

      -- Чистим глобальные переменные
      rFILES.delete;
      rSHAREDSTRINGS.delete;
      rSTYLEIDS.delete;

      DBMS_LOB.FREETEMPORARY( cST_NUMFMTS );
      DBMS_LOB.FREETEMPORARY( cST_FONTS );
      DBMS_LOB.FREETEMPORARY( cST_FILLS );
      DBMS_LOB.FREETEMPORARY( cST_BORDERS );
      DBMS_LOB.FREETEMPORARY( cST_CELLSTYLEXFS );
      DBMS_LOB.FREETEMPORARY( cST_DXFS );
      DBMS_LOB.FREETEMPORARY( cST_CELLXFS );
      DBMS_LOB.FREETEMPORARY( cST_CELLSTYLES );
      DBMS_LOB.FREETEMPORARY( cWS_STATICCELLS );
    end if;

    return bRESULT;
  end;

  procedure OPEN_REPORT         --Создание отчета
  (
    nTYPE           in number   := 0,                         -- Тип отчета ( 0 - XLSXML, 1 - XLSX )
    sAUTHOR         in varchar2 := 'LLC FINATEK',             -- Автор
    sLASTAUTHOR     in varchar2 := 'NO',                      -- Последний редактировавший
    sCOMPANY        in varchar2 := 'LLC FINATEK',             -- Организация
    sAPP            in varchar2 := '2RAMZES.RU',              -- Приложение
    sENCODING       in varchar2 := 'Windows-1251',            -- Кодировка
    nSTARTINDENT    in number   := 0,                         -- Начальный отступ
    nADDDEFSTYLE    in number   := 1                          -- Добавить стиль по умолчанию (Arial Cyr, 10)
  )
  is
    sFILENAME       varchar2(240);
  begin
    -- Выставим default контекст
    SET_DEFAULT_VARS;

    nREPORTTYPE := nTYPE;
    nCURRENTSTATE := 10;
    rSHEETNAMES := tNAMES();
    sXMLHEAD := '<?xml version="1.0" encoding="' || sENCODING || '"?>';
    iCHARSETID := NLS_CHARSET_ID( UTL_I18N.MAP_CHARSET( sENCODING, UTL_I18N.GENERIC_CONTEXT, UTL_I18N.IANA_TO_ORACLE ) );
    if iCHARSETID is null then
      AP_EXCEPTION( 0, 'Кодировка "%s" не определена', sENCODING );
    end if;

    DBMS_LOB.CREATETEMPORARY( сST_RUNTITLE, true );
    DBMS_LOB.CREATETEMPORARY( cST_CONDFORMAT, true );
    rCONDFORMAT.DELETE;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      if cCLOB is not null then
        DBMS_LOB.freetemporary(cCLOB);
      end if;
      DBMS_LOB.createtemporary(cCLOB, true);

      nINDENT := nSTARTINDENT;

      PUT_LINE( sXMLHEAD );
      PUT_LINE( '<?mso-application progid="Excel.Sheet"?>');
      PUT_LINE( '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
      PUT_LINE( 'xmlns:o="urn:schemas-microsoft-com:office:office"');
      PUT_LINE( 'xmlns:x="urn:schemas-microsoft-com:office:excel"');
      PUT_LINE( 'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
      PUT_LINE( 'xmlns:html="http://www.w3.org/TR/REC-html40">');
      nINDENT := nINDENT+1;
      PUT_LINE( '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">');
      nINDENT := nINDENT+1;
      PUT_LINE( '<Author>'||SP_CHAR_REPL(sAUTHOR)||'</Author>');
      PUT_LINE( '<LastAuthor>'|| SP_CHAR_REPL(sLASTAUTHOR) ||'</LastAuthor>');
      PUT_LINE( '<Created>'||sysdate||'</Created>');
      PUT_LINE( '<Company>'|| SP_CHAR_REPL(sCOMPANY) ||'</Company>');
      PUT_LINE( '<NameOfApplication>'|| SP_CHAR_REPL(sAPP) ||'</NameOfApplication>');
      nINDENT := nINDENT-1;
      PUT_LINE( '</DocumentProperties>');

      PUT_LINE( '<OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">');
      nINDENT := nINDENT+1;
      PUT_LINE( '<AllowPNG/>');
      nINDENT := nINDENT-1;
      PUT_LINE( '</OfficeDocumentSettings>');
      PUT_LINE( '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">');
      nINDENT := nINDENT+1;
      PUT_LINE( '<WindowHeight>12135</WindowHeight>');
      PUT_LINE( '<WindowWidth>28800</WindowWidth>');
      PUT_LINE( '<WindowTopX>0</WindowTopX>');
      PUT_LINE( '<WindowTopY>0</WindowTopY>');
      PUT_LINE( '<RefModeR1C1/>');
      PUT_LINE( '<ProtectStructure>False</ProtectStructure>');
      PUT_LINE( '<ProtectWindows>False</ProtectWindows>');
      nINDENT := nINDENT-1;
      PUT_LINE( '</ExcelWorkbook>');

    -- XLSX
    elsif nREPORTTYPE = 1 then

      iSHEETID := 0;
      iSTRINGID := 0;
      iSTYLEID := 0;
      iDXFS := 0;
      lCOLSOPEN := false;
      rSHAREDSTRINGS.delete;
      rSTYLEIDS.delete;

      -- _rels\.rels - отношения верхнего уровня
      -- Содержит отношения уровня документа (ссылки на книги и свойства документа)
      sFILENAME := '_rels/.rels';
      rFILES( sFILENAME ) := sXMLHEAD;
      PUT_LINE( sFILENAME, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' );
      PUT_LINE( sFILENAME, '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' );
      -- PUT_LINE( sFILENAME, '<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="/xl/workbook.xml" Id="wb" />' );
      PUT_LINE( sFILENAME, '</Relationships>' );

      -- [Content_Types].xml - описатели контента файлов
      -- Содержит типы контента, определяемые по расширениям, а также переопределения типов для конкретных файлов
      sFILENAME := '[Content_Types].xml';
      rFILES( sFILENAME ) := sXMLHEAD;
      PUT_LINE( sFILENAME, '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' );
      PUT_LINE( sFILENAME, '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>' );
      PUT_LINE( sFILENAME, '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml" />' );
      PUT_LINE( sFILENAME, '<Default Extension="xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml" />' );
      PUT_LINE( sFILENAME, '<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>' );

      -- xl\workbook.xml - книга
      -- Содержит описание листов книги и имен уровня книги
      sFILENAME := 'xl/workbook.xml';
      rFILES( sFILENAME ) := sXMLHEAD;
      --PUT_LINE( sFILENAME, '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' );
      PUT_LINE( sFILENAME, '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' );
      PUT_LINE( sFILENAME, '<fileVersion appName="xl" lastEdited="4" lowestEdited="4" rupBuild="4506"/>' );
      -- Взято из Libro
      PUT_LINE( sFILENAME, '<workbookPr backupFile="false" showObjects="all" date1904="false"/>' );
      -- размер открываемого окна, активный лист
      PUT_LINE( sFILENAME, '<bookViews><workbookView showHorizontalScroll="true" showVerticalScroll="true" showSheetTabs="true" xWindow="0" yWindow="0" windowWidth="16384" windowHeight="8192" activeTab="0"/></bookViews>' );
      PUT_LINE( sFILENAME, '<sheets>' );

      -- xl\_rels\workbook.xml.rels - отношения
      -- Содержит отношения уровня книги (ссылки на листы, стили, темы, ss-строки)
      sFILENAME := 'xl/_rels/workbook.xml.rels';
      rFILES( sFILENAME ) := sXMLHEAD;
      PUT_LINE( sFILENAME, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' );
      PUT_LINE( sFILENAME, '<Relationship Id="wbss" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>' );
      PUT_LINE( sFILENAME, '<Relationship Id="wbst" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>' );

      -- xl\sharedStrings.xml - общие строки
      -- Содержит таблицу общих строк
      sFILENAME := 'xl/sharedStrings.xml';
      rFILES( sFILENAME ) := sXMLHEAD;
      PUT_LINE( sFILENAME, '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" >' );

      -- xl\styles.xml
      -- Содержит стили книги
      sFILENAME := 'xl/styles.xml';
      rFILES( sFILENAME ) := sXMLHEAD;
      PUT_LINE( sFILENAME, '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' );

      DBMS_LOB.CREATETEMPORARY( cST_NUMFMTS, true );
      DBMS_LOB.CREATETEMPORARY( cST_FONTS, true );
      DBMS_LOB.CREATETEMPORARY( cST_FILLS, true );
      DBMS_LOB.CREATETEMPORARY( cST_BORDERS, true );
      DBMS_LOB.CREATETEMPORARY( cST_CELLSTYLEXFS, true );
      DBMS_LOB.CREATETEMPORARY( cST_DXFS, true );
      DBMS_LOB.CREATETEMPORARY( cST_CELLXFS, true );
      DBMS_LOB.CREATETEMPORARY( cST_CELLSTYLES, true );
      DBMS_LOB.CREATETEMPORARY( cWS_STATICCELLS, true );
    else
      AP_EXCEPTION( 0, 'Не найден тип отчета с кодом "%s"', nREPORTTYPE );
    end if;

    if nADDDEFSTYLE = 1 then
      ADD_STYLE
      (
        sSTYLE     => 'Default'  ,
        sNAME      => 'Normal'   ,
        nFONTSIZE  => 8          ,
        sFONTNAME  => 'Verdana'
      );
    end if;
  end;

  procedure OPEN_SHEET     --Открывает лист
  (
    sSHEETNAME                 in varchar2 := null,                      -- Название листа. Если не задано, то "<Тек. Дата> - РАМЗЭС"
    nPROTECTED                 in number := 1,                           -- Защищенный лист
    sDATA                      in varchar2 := 'Подготовлено в ЭС РАМЗЭС', -- Данные о листе
    nHSTATICCELLS              in number := 0,                           -- Количество заголовочных ячеек
    nVSTATICCELLS              in number := 0,
    nOPTIMIZE_INSERT           in number := 0,                           -- Оптимизация добавления ячеек
    sPASSWORD                  in varchar2 default null,                 -- Пароль для снятия защиты листа
    sORIENTATION               in varchar2 default 'Landscape',          -- Ориентация листа Portrait или Landscape
    sDEFAULTROWHEIGHT          in varchar2 default '10.5'                -- Высота строки по умолчанию
  )
  is
    svSHEETNAME                varchar2(2000) := CHECK_SHEET_NAME( nvl( sSHEETNAME, to_char( sysdate, 'DD.MM.YYYY' ) || ' РАМЗЭС' ) );
    cSHEET_CLOB                clob;
  begin
    if nCURRENTSTATE != 10 and nCURRENTSTATE != 20 and nCURRENTSTATE != 100 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Создавать листы нужно либо друг за другом после CLOSE_SHEET, либо после создания стилей, либо после OPEN_REPORT непосредственно!');
    end if;
    nCURRENTSTATE := 30;

    -- Проверка существования листа
    for i in 1..rSHEETNAMES.count
    loop
      if rSHEETNAMES( i ) = svSHEETNAME then
        AP_EXCEPTION( 0, 'Лист с именем "%s" уже существует в отчете. Повторное создание листа с таким именем невозможно', svSHEETNAME );
      end if;
    end loop;
    rSHEETNAMES.extend;
    rSHEETNAMES( rSHEETNAMES.last ) := svSHEETNAME;

    nROWCOUNT := 0;
    iCOLUMNID := 1;

    delete from A_XLSCELLS;
    delete from A_XLSROWS;

    lOPTIMIZE_INSERT := nOPTIMIZE_INSERT != 0;
    if lOPTIMIZE_INSERT then
      vXLSROWS.delete;
      vXLSCELLS.delete;
      rNUMCOL.delete;
      rINDEX_XLSCELLS.delete;
    end if;

    APKG_XLSREP.sORIENTATION := sORIENTATION;

    APKG_XLSREP.nlHSTATICCELLS := nHSTATICCELLS;
    APKG_XLSREP.nlVSTATICCELLS := nVSTATICCELLS;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      slDATA := sDATA;

      -- сброс параметров автофильтра
      nAUTOFILTERX := null;
      nAUTOFILTERX_C1 := null;
      nAUTOFILTERX_C2 := null;
      nAUTOFILTERX_R1 := null;
      nAUTOFILTERX_R2 := null;

      sCURRENTSHEET := svSHEETNAME;
      if lSTYLESOPEN then
        nINDENT := nINDENT-1;
        PUT_LINE( '</Styles>');
        lSTYLESOPEN := false;
      end if;

      PUT_LINE(
                 '<Worksheet ss:Name="' || SP_CHAR_REPL(sCURRENTSHEET) || '"' ||
                 case
                   when nPROTECTED=1 then ' ss:Protected="1">'
                   else '>'
                 end
               );

      nINDENT := nINDENT + 1;

    -- XLSX
    elsif nREPORTTYPE = 1 then
      APKG_XLSREP.nPROTECTED := nPROTECTED;
      APKG_XLSREP.sPASSWORD  := sPASSWORD;
      slDATA := sDATA; --Ermakov
      iSHEETID := iSHEETID + 1;
      sCURRENTSHEET := 'xl/worksheets/sheet' || iSHEETID || '.xml';

      DBMS_LOB.createtemporary( cSHEET_CLOB, true );
      rFILES( sCURRENTSHEET ) := cSHEET_CLOB;
      PUT_LINE( sCURRENTSHEET, sXMLHEAD );
      --rFILES( sCURRENTSHEET ) := sXMLHEAD;

      PUT_LINE( sCURRENTSHEET, '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' );
      -- разместить не более чем на 1 стр. в ширину
      PUT_LINE( sCURRENTSHEET,
        '<sheetPr><pageSetUpPr fitToPage="1"/></sheetPr>' );
      -- Заголовок
      PUT_LINE( sCURRENTSHEET,
        '<sheetViews><sheetView workbookViewId="0">' );
      if nHSTATICCELLS != 0 and nVSTATICCELLS != 0 then
        PUT_LINE( sCURRENTSHEET,
          '<pane xSplit="' || nVSTATICCELLS || '" ySplit="' || nHSTATICCELLS || '" ' ||
          'topLeftCell="' || GET_COL_NAME( nVSTATICCELLS + 1) || to_char( nHSTATICCELLS + 1 ) || '" activePane="bottomRight" state="frozen"/>' ||
          '<selection pane="topRight" activeCell="A1" sqref="A1"/>' ||
          '<selection pane="bottomLeft" activeCell="A1" sqref="A1"/>' ||
          '<selection pane="bottomRight" activeCell="A1" sqref="A1"/>' );

      elsif nHSTATICCELLS != 0 then
        PUT_LINE( sCURRENTSHEET,
          '<pane xSplit="' || nVSTATICCELLS || '" ySplit="' || nHSTATICCELLS || '" ' ||
          'topLeftCell="A'|| to_char( nHSTATICCELLS + 1 ) || '" activePane="bottomLeft" state="frozen"/>' ||
          '<selection pane="bottomLeft"/>');

      elsif nVSTATICCELLS != 0 then
        PUT_LINE( sCURRENTSHEET,
          '<pane xSplit="' || nVSTATICCELLS || '" ' ||
          'topLeftCell="' || GET_COL_NAME( nVSTATICCELLS + 1) ||'1" activePane="topRight" state="frozen"/>' ||
          '<selection pane="topRight"/>' );

      else
        PUT_LINE( sCURRENTSHEET,
          '<selection sqref="A1:A1"/>' );
      end if;
      PUT_LINE( sCURRENTSHEET,
        '</sheetView></sheetViews>' );

      PUT_LINE( sCURRENTSHEET, '<sheetFormatPr defaultRowHeight="' || sDEFAULTROWHEIGHT || '"/>' );

      PUT_LINE( 'xl/workbook.xml', '<sheet name="' || svSHEETNAME || '" sheetId="' || iSHEETID || '" r:id="rId' || iSHEETID
                || '" />' );
      PUT_LINE( 'xl/_rels/workbook.xml.rels', '<Relationship Id="rId' || iSHEETID || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
                || 'Target="worksheets/sheet' || iSHEETID || '.xml" />' );
      PUT_LINE( '[Content_Types].xml', '<Override PartName="/xl/worksheets/sheet' || iSHEETID || '.xml" '
                || 'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml" />' );
    end if;
  end;

  procedure OPEN_TABLE -- Открыть табличную область
  is
  begin
    if nCURRENTSTATE != 30 and nCURRENTSTATE != 40 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Создавать таблицу данных можно только после открытия листа (OPEN_SHEET) или объявления именованных регионов (ADD_NAMED_RANGE).');
    end if;
    nCURRENTSTATE := 50;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      if lNAMESOPEN then
        nINDENT := nINDENT-1;
        PUT_LINE( '</Names>');
        lNAMESOPEN := false;
      end if;

      PUT_LINE( '<Table>');
      nINDENT := nINDENT+1;

    -- XLSX
    elsif nREPORTTYPE = 1 then
      null;
    end if;
  end;

  procedure CLOSE_REPORT
  is
    sFILENAME         varchar2(240);
  begin
    if nCURRENTSTATE in ( 10, 20 ) then
      AP_EXCEPTION( 0, 'В сформированном отчете нет ни одного листа.' );
    elsif nCURRENTSTATE  != 100 then
      AP_EXCEPTION( 0, 'Отчет сформирован некорректно. Завершать построение отчета в состоянии "%s" нельзя.'||sqlerrm,
                      DECODE_STATE( nCURRENTSTATE ) );
    end if;
    nCURRENTSTATE := 200;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      nINDENT := nINDENT - 1;
      PUT_LINE( '</Workbook>' );
      vXLSROWS.delete;
      vXLSCELLS.delete;

    -- XLSX
    elsif nREPORTTYPE = 1 then
      PUT_LINE( 'xl/workbook.xml', '</sheets>' );

      -- Закрепление строк при печати
      if cWS_STATICCELLS is not null and DBMS_LOB.GETLENGTH( cWS_STATICCELLS ) != 0 then
        PUT_LINE( 'xl/workbook.xml', '<definedNames>' );
        rFILES( 'xl/workbook.xml' ) := rFILES( 'xl/workbook.xml' ) || cWS_STATICCELLS;
        PUT_LINE( 'xl/workbook.xml', '</definedNames>' );
      end if;

      -- fullCalcOnLoad="1" This will cause the Excel document to perform the caluclations within all the workbooks when the file is opened.
      PUT_LINE( 'xl/workbook.xml', '<calcPr fullCalcOnLoad="1" iterateCount="100" refMode="A1" iterate="false" iterateDelta="0.001"/>' );

      PUT_LINE( 'xl/workbook.xml', '</workbook>' );
      PUT_LINE( 'xl/_rels/workbook.xml.rels', '</Relationships>' );
      PUT_LINE( 'xl/sharedStrings.xml', '</sst>' );
      PUT_LINE( '[Content_Types].xml', '</Types>' );

      sFILENAME := 'xl/styles.xml';
      PUT_LINE( sFILENAME, '<numFmts>' );
      rFILES( sFILENAME ) := rFILES( sFILENAME ) || cST_NUMFMTS;
      PUT_LINE( sFILENAME, '</numFmts>' );
      PUT_LINE( sFILENAME, '<fonts>' );
      rFILES( sFILENAME ) := rFILES( sFILENAME ) || cST_FONTS;
      PUT_LINE( sFILENAME, '</fonts>' );
      PUT_LINE( sFILENAME, '<fills>' );
      rFILES( sFILENAME ) := rFILES( sFILENAME ) || cST_FILLS;
      PUT_LINE( sFILENAME, '</fills>' );
      PUT_LINE( sFILENAME, '<borders>' );
      rFILES( sFILENAME ) := rFILES( sFILENAME ) || cST_BORDERS;
      PUT_LINE( sFILENAME, '</borders>' );
      PUT_LINE( sFILENAME, '<cellStyleXfs>' );
      rFILES( sFILENAME ) := rFILES( sFILENAME ) || cST_CELLSTYLEXFS;
      PUT_LINE( sFILENAME, '</cellStyleXfs>' );
      PUT_LINE( sFILENAME, '<cellXfs>' );
      rFILES( sFILENAME ) := rFILES( sFILENAME ) || cST_CELLXFS;
      PUT_LINE( sFILENAME, '</cellXfs>' );
      PUT_LINE( sFILENAME, '<cellStyles>' );
      rFILES( sFILENAME ) := rFILES( sFILENAME ) || cST_CELLSTYLES;
      PUT_LINE( sFILENAME, '</cellStyles>' );
      -- формат условного форматирования
      if CST_DXFS is not null then
        PUT_LINE( sFILENAME, '<dxfs count="'||iDXFS||'">' );
        rFILES( sFILENAME ) := rFILES( sFILENAME ) || CST_DXFS;
        PUT_LINE( sFILENAME, '</dxfs>' );
      else
        PUT_LINE( sFILENAME, '<dxfs count="0"/>' );
      end if;
      --

      -- 2003 Office добавляет
      --PUT_LINE( sFILENAME, '<dxfs count="0"/>' );
      PUT_LINE( sFILENAME, '<tableStyles count="0" defaultTableStyle="TableStyleMedium9" defaultPivotStyle="PivotStyleLight16"/>' );
      PUT_LINE( sFILENAME, '</styleSheet>' );
    end if;
  end;

  procedure CLOSE_SHEET  --Закрывает лист. Доступна только внутри пакета.
  (
    bSHOWGRID                  in boolean default true,
    bMARGINBOTTOM         in varchar  default '0.4',
    bMARGINLEFT           in varchar  default '0.4',
    bMARGINRIGHT          in varchar  default '0.4',
    bMARGINTOP            in varchar  default '0.4'
  )
  is
    sSTATICCELLS               varchar2(2000);
    iCOLNUMBER                 integer;
  begin
    if nCURRENTSTATE != 90 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Перед закрытием листа надо закрыть таблицу с помощью CLOSE_TABLE.');
    end if;
    nCURRENTSTATE := 100;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      for cur in (select r.rn from A_XLSROWS r where r.skip=0 and r.pagebreak=1 order by rn)
      loop
        if not lPAGEBREAKSOPEN then
          PUT_LINE('<PageBreaks xmlns="urn:schemas-microsoft-com:office:excel">');
          lPAGEBREAKSOPEN := true;
          nINDENT := nINDENT + 1;
          PUT_LINE('<RowBreaks>');
          nINDENT := nINDENT + 1;
        end if;
        PUT_LINE('<RowBreak>');
        nINDENT := nINDENT + 1;
        PUT_LINE('<Row>' || cur.rn || '</Row>');
        nINDENT := nINDENT - 1;
        PUT_LINE('</RowBreak>');
      end loop;

      if lPAGEBREAKSOPEN then
        nINDENT := nINDENT - 1;
        PUT_LINE('</RowBreaks>');
        nINDENT := nINDENT - 1;
        PUT_LINE('</PageBreaks>');
        lPAGEBREAKSOPEN := false;
      end if;

      PUT_LINE('<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">');
      nINDENT := nINDENT + 1;
      PUT_LINE('<PageSetup>');
      nINDENT := nINDENT + 1;
      PUT_LINE('<Layout x:Orientation="' || sORIENTATION || '"/>');
      -- колонтитулы
      if сST_RUNTITLE is not null then
        PUT_LINE( сST_RUNTITLE );
      end if;
      --
      PUT_LINE('<PageMargins x:Bottom="'||bMARGINBOTTOM||'" x:Left="'||bMARGINLEFT||'" x:Right="'||bMARGINRIGHT||'" x:Top="'||bMARGINTOP||'"/>');
      nINDENT := nINDENT - 1;
      PUT_LINE('</PageSetup>');
      PUT_LINE('<FitToPage/>'); -- Наверное, разместить разместить не более чем на 1 стр. в ширину
      PUT_LINE('<Print>');
      nINDENT := nINDENT + 1;
      PUT_LINE('<FitHeight>0</FitHeight>'); -- Наверное, разместить разместить не более чем на "пусто" стр. в высоту
      PUT_LINE('<ValidPrinterInfo/>');
      PUT_LINE('<PaperSizeIndex>9</PaperSizeIndex>');
      PUT_LINE('<HorizontalResolution>600</HorizontalResolution>');
      PUT_LINE('<VerticalResolution>600</VerticalResolution>');
      nINDENT := nINDENT - 1;
      PUT_LINE('</Print>');
      PUT_LINE('<Selected/>');
      if not bSHOWGRID then
        PUT_LINE('<DoNotDisplayGridlines/>'); -- Не показывать сетку
      end if;
      PUT_LINE('<FreezePanes/>');
      PUT_LINE('<FrozenNoSplit/>');
      if nlHSTATICCELLS > 0 then
        PUT_LINE('<SplitHorizontal>' || nlHSTATICCELLS || '</SplitHorizontal>');
        PUT_LINE('<TopRowBottomPane>' || nlHSTATICCELLS || '</TopRowBottomPane>');
      end if;
      if nlVSTATICCELLS > 0 then
        PUT_LINE('<SplitVertical>' || nlVSTATICCELLS || '</SplitVertical>');
        PUT_LINE('<LeftColumnRightPane>' || nlVSTATICCELLS || '</LeftColumnRightPane>');
      end if;
      PUT_LINE('<ActivePane>0</ActivePane>');
      PUT_LINE('<Panes>');
      nINDENT := nINDENT + 1;
      PUT_LINE('<Pane>');
      nINDENT := nINDENT + 1;
      PUT_LINE('<Number>2</Number>');
      PUT_LINE('<ActiveRow>1</ActiveRow>');
      PUT_LINE('<ActiveCol>1</ActiveCol>');
      nINDENT := nINDENT - 1;
      PUT_LINE('</Pane>');
      nINDENT := nINDENT - 1;
      PUT_LINE('</Panes>');
      PUT_LINE('<ProtectObjects>False</ProtectObjects>');
      PUT_LINE('<ProtectScenarios>False</ProtectScenarios>');
      nINDENT := nINDENT - 1;
      PUT_LINE('</WorksheetOptions>');

      if nAUTOFILTERX = 1 then
        PUT_LINE('<AutoFilter x:Range="R' || to_char(nAUTOFILTERX_R1)
                                    || 'C' || to_char(nAUTOFILTERX_C1)
                                    || ':R' || to_char(nAUTOFILTERX_R2)
                                    || 'C' || to_char(nAUTOFILTERX_C2)
                                    || '" xmlns="urn:schemas-microsoft-com:office:excel">' );
        PUT_LINE('</AutoFilter>');
      end if;

      -- !!! вынести в отдельнуюж процедуру
      -- условное форматирование
      for condf in
      (
        select distinct c.CONDFORMAT
          from A_XLSCELLS c
         where c.CONDFORMAT is not null
           and c.SKIP = 0
      )
      loop
        sCELL_CONDFORMAT := null;

        -- ячейки
        for cur_rows in
        (
          select r.RN
            from A_XLSROWS r
           where r.SKIP=0
           order by r.RN
        )
        loop
          iCOLNUMBER := 0;

          for cur_cells in
          (
            select c.CONDFORMAT,
                   c.MERGEACROSS
              from A_XLSCELLS c
             where c.PRN = cur_rows.RN
               and c.SKIP = 0
             order by c.RN
          )
          loop
            iCOLNUMBER := iCOLNUMBER + 1;

            -- объединение вправо
            if cur_cells.mergeacross > 0 then
              iCOLNUMBER := iCOLNUMBER + cur_cells.mergeacross;
            end if;

            if cur_cells.CONDFORMAT = condf.CONDFORMAT then
              -- !!! по-хорошему, нужно делать через интервалы
              if sCELL_CONDFORMAT is null then
                sCELL_CONDFORMAT := sCELL_CONDFORMAT||'R'||to_char(cur_rows.rn)||'C'||to_char(iCOLNUMBER);
              else
                sCELL_CONDFORMAT := sCELL_CONDFORMAT||','||'R'||to_char(cur_rows.rn)||'C'||to_char(iCOLNUMBER);
              end if;
            end if;
          end loop;
        end loop;

        begin
          PUT_LINE( replace( rCONDFORMAT( condf.CONDFORMAT ), '##RANGE##', sCELL_CONDFORMAT ) );
        exception
          when no_data_found then
            ap_exception( 0, 'К ячейке применяется условное форматирование "%s", которое не описано!', condf.CONDFORMAT );
        end;
      end loop;

      nINDENT := nINDENT - 1;

      PUT_LINE( '</Worksheet>');

    -- XLSX
    elsif nREPORTTYPE = 1 then
      -- Закрепление строк при печати
      /*if nlVSTATICCELLS != 0 then
        sSTATICCELLS := '''' || rSHEETNAMES( iSHEETID ) || '''!$' || GET_COL_NAME( nlVSTATICCELLS ) || ':$' || GET_COL_NAME( nlVSTATICCELLS );
      end if;*/

      if nlHSTATICCELLS != 0 then
        if sSTATICCELLS is not null then
          sSTATICCELLS := sSTATICCELLS || ',';
        end if;

        sSTATICCELLS := sSTATICCELLS || '''' || rSHEETNAMES( iSHEETID ) || '''!$' || to_char( nlHSTATICCELLS ) || ':$'|| to_char( nlHSTATICCELLS );
      end if;

      if sSTATICCELLS is not null then
        cWS_STATICCELLS := cWS_STATICCELLS || '<definedName name="_xlnm.Print_Titles" localSheetId="' || to_char( iSHEETID - 1 ) || '">'
                                           || sSTATICCELLS || '</definedName>';
      end if;

    /*НОВЫЙ ФУНКЦИОНАЛ: добавление картинки "Печать с подписью" для Минздрав Сахалин. GALA*/
      if rDRAWINGS.COUNT >0 then
        PUT_LINE( sCURRENTSHEET, '<drawing r:id="rId1"/>' );
        --PUT_LINE( 'xl/drawings/drawing1.xml', '</xdr:wsDr>' );
      end if;
    /*------------------окончание--------------------*/

      -- Много кода вынесено во FLUSH
      PUT_LINE( sCURRENTSHEET, '</worksheet>' );

    end if;
  end;

  procedure CLOSE_TABLE              -- Закрыть табличную область. Доступна только внутри пакета
  is
  begin
    if nCURRENTSTATE != 80 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Перед закрытием таблицы необходимо создать и выгрузить ячейки с помощью ADD_ROW, ADD_CELL и FLUSH_ROWCELLS.');
    end if;
    nCURRENTSTATE := 90;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      nINDENT := nINDENT-1;
      PUT_LINE( '</Table>' );

    -- XLSX
    elsif nREPORTTYPE = 1 then
      null;
    end if;
  end;

  procedure CLOSE_TABLE_AND_SHEET    --Закрыть табличную область и лист. Доступна извне.
  (
    bSHOWGRID             in boolean default true,
    bMARGINBOTTOM         in varchar  default '0.4',
    bMARGINLEFT           in varchar  default '0.4',
    bMARGINRIGHT          in varchar  default '0.4',
    bMARGINTOP            in varchar  default '0.4'

  )
  is
  begin
    CLOSE_TABLE;
    CLOSE_SHEET( bSHOWGRID, bMARGINBOTTOM, bMARGINLEFT, bMARGINRIGHT, bMARGINTOP);
  end;

-- таблица соответствия RGB и индексированных цветов для xlsx
-- #FFFFFF - 0 #FFFFFF - 1 #FF0000 - 2 #00FF00 - 3 #0000FF - 4 #FFFF00 - 5 #FF00FF - 6 #00FFFF - 7 #800000 - 8 #008000 - 9
-- #000080 - 10 #808000 - 11 #800080 - 12 #008080 - 13 #C0C0C0 - 14 #808080 - 15 #9999FF - 16 #993366 - 17 #FFFFCC - 18 #CCFFFF - 19
-- #660066 - 20 #FF8080 - 21 #0066CC - 22 #CCCCFF - 23 #000080 - 24 #FF00FF - 25 #FFFF00 - 26 #00FFFF - 27 #800080 - 28 #800000 - 29
-- #008080 - 30 #0000FF - 31 #00CCFF - 32 #CCFFFF - 33 #CCFFCC - 34 #FFFF99 - 35 #99CCFF - 36 #FF99CC - 37 #CC99FF - 38 #FFCC99 - 39
-- #3366FF - 40 #33CCCC - 41 #99CC00 - 42 #FFCC00 - 43 #FF9900 - 44 #FF6600 - 45 #666699 - 46 #969696 - 47 #003366 - 48 #339966 - 49
-- #003300 - 50 #333300 - 51 #993300 - 52 #993366 - 53 #333399 - 54 #333333 - 55

  procedure ADD_STYLE      --Объявляет стиль
  (
    sSTYLE                     in varchar2    := 'Default',                   -- ID стиля
    sNAME                      in varchar2    := null,                        -- Наименование стиля
    sHALIGNMENT                in varchar2    := 'Left',                      -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
    sVALIGNMENT                in varchar2    := 'Center',                    -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
    nTEXTROTATION               in varchar2    := 0,                                -- Поворот текста в ячейке (в градусах от 0 до 180)
    sINDENT                    in varchar2    := '0',                         -- Отступ
    nWRAPTEXT                  in number      := 0,                           -- Перенос текста (0, 1)
    sBORDERTOPSTYLE            in varchar2    := 'Continuous',                -- Верхняя граница ячейки (Continuous, Dot)
    sBORDERBOTTOMSTYLE         in varchar2    := 'Continuous',                -- Нижняя граница ячейки (Continuous, Dot)
    sBORDERLEFTSTYLE           in varchar2    := 'Continuous',                -- Левая граница ячейки (Continuous, Dot)
    sBORDERRIGHTSTYLE          in varchar2    := 'Continuous',                -- Правая граница ячейки (Continuous, Dot)
    nBORDERTOPWEIGHT           in number      := 0,                           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
    nBORDERBOTTOMWEIGHT        in number      := 0,                           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
    nBORDERLEFTWEIGHT          in number      := 0,                           -- Левая граница ячейки, толщина (если 0, то не формируется)
    nBORDERRIGHTWEIGHT         in number      := 0,                           -- Правая граница ячейки, толщина (если 0, то не формируется)
    sFONTNAME                  in varchar2    := 'Verdana',                   -- Название шрифта
    sCHARSET                   in varchar2    := '204',                       -- Код набора символов
    nFONTSIZE                  in number      := 8,                           -- Размер шрифта
    nFONTBOLD                  in number      := 0,                           -- Болд (0, 1)
    nFONTITALIC                in number      := 0,                           -- Курсив
    sFONTCOLOR                 in varchar2    := '#000000',                   -- Цвет шрифта '#FFFFFF' или индексированный цвет для xlsx, см. таблицу соответствия выше
    sBACKCOLOR                 in varchar2    := null,                        -- Цвет фона '#FFFFFF'
    sPATTERN                   in varchar2    := null,                        -- Кисть фона 'Solid'
    sNUMBERFORMAT              in varchar2    := null,                        -- Формат числа
    nPROTECTION                in number      := 1,                           -- Защитить ячейку
    sBORDERCOLOR               in varchar2    := null
  )
  is
    iNUMFMTID                  integer;

    function XLSX_DECODE_BORDERWEIGHT
    (
      nWEIGHT                  in number
    )
    return varchar2
    is
    begin
      if nWEIGHT = 1 then
        return 'style="thin"';
      elsif nWEIGHT = 2 then
        return 'style="medium"';
      elsif nWEIGHT = 0 then
        return null;
      else
        AP_EXCEPTION( 0, 'Толщина границы "%s" в отчете типа XLSX недопустима', nWEIGHT );
      end if;
    end;
  begin

    if nCURRENTSTATE != 10 and nCURRENTSTATE != 20 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Создавать стили нужно непосредственно после вызова OPEN_REPORT!');
    end if;
    nCURRENTSTATE := 20;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      if not lSTYLESOPEN then
        PUT_LINE( '<Styles>');
        lSTYLESOPEN := true;
        nINDENT := nINDENT+1;
      end if;

      PUT_LINE( '<Style ss:ID="' || SP_CHAR_REPL(sSTYLE) || '" '
                || case when sNAME is not null then 'ss:Name="' || sNAME || '"' end || ' >');
      nINDENT := nINDENT+1;
      PUT_LINE( '<Alignment ss:Horizontal="' || sHALIGNMENT || '"' ||
                  ' ss:Vertical="' || sVALIGNMENT || '"' ||
                  case when sINDENT != '0' then ' ss:Indent="' || sINDENT || '"' end ||
                  case when nWRAPTEXT=0 then '/>' else ' ss:WrapText="1"/>' end);

      if nPROTECTION = 0 then
          PUT_LINE('<Protection ss:Protected="0"/>');
          nINDENT := nINDENT+1;
      end if;

      if nBORDERTOPWEIGHT!=0 or nBORDERBOTTOMWEIGHT!=0 or nBORDERLEFTWEIGHT!=0 or nBORDERRIGHTWEIGHT!=0
      then
        PUT_LINE( '<Borders>');
        nINDENT := nINDENT+1;
        if nBORDERTOPWEIGHT!=0 then
          PUT_LINE( '<Border ss:Position="Top" ss:LineStyle="' || sBORDERTOPSTYLE || '" ss:Weight="'|| nBORDERTOPWEIGHT ||'"/>');
        end if;

        if nBORDERBOTTOMWEIGHT!=0 then
          PUT_LINE( '<Border ss:Position="Bottom" ss:LineStyle="'|| sBORDERBOTTOMSTYLE ||'" ss:Weight="'|| nBORDERBOTTOMWEIGHT ||'"/>');
        end if;

        if nBORDERLEFTWEIGHT!=0 then
          PUT_LINE( '<Border ss:Position="Left" ss:LineStyle="'|| sBORDERLEFTSTYLE ||'" ss:Weight="'|| nBORDERLEFTWEIGHT ||'"/>');
        end if;

        if nBORDERRIGHTWEIGHT!=0 then
          PUT_LINE( '<Border ss:Position="Right" ss:LineStyle="'|| sBORDERRIGHTSTYLE ||'" ss:Weight="'|| nBORDERRIGHTWEIGHT ||'"/>');
        end if;
        nINDENT := nINDENT-1;
        PUT_LINE( '</Borders>');
      else
        PUT_LINE( '<Borders/>');
      end if;
      PUT_LINE( '<Font ss:FontName="' || sFONTNAME ||
                     '" x:CharSet="' || sCHARSET || '" x:Family="Swiss"' ||
                     ' ss:Size="' || nFONTSIZE || '"' ||
                     ' ss:Color="' || sFONTCOLOR || '"' ||
                     case when nFONTITALIC = 1 then ' ss:Italic="1"' end ||
                     case when nFONTBOLD=0 then '/>' else ' ss:Bold="1"/>' end);

      if sBACKCOLOR is not null then
        PUT_LINE( '<Interior ss:Color="' || sBACKCOLOR || '"' ||
                   ' ss:Pattern="' || nvl( sPATTERN, 'Solid' )||'"/>' );
      end if;

      if sNUMBERFORMAT is not null then
        PUT_LINE( '<NumberFormat ss:Format="'|| SP_CHAR_REPL(sNUMBERFORMAT) ||'"/>');
      end if;
      nINDENT := nINDENT-1;
      PUT_LINE( '</Style>' );
    -- XLSX
    elsif nREPORTTYPE = 1 then
      /*
        Build in ID's

        0   General
        1   0
        2   0.00
        3   #,##0
        4   #,##0.00
        9   0%
        10  0.00%
        11  0.00E+00
        12  # ?/?
        13  # ??/??
        14  mm-dd-yy
        15  d-mmm-yy
        16  d-mmm
        17  mmm-yy
        18  h:mm AM/PM
        19  h:mm:ss AM/PM
        20  h:mm
        21  h:mm:ss
        22  m/d/yy h:mm
        37  #,##0 ;(#,##0)
        38  #,##0 ;[Red](#,##0)
        39  #,##0.00;(#,##0.00)
        40  #,##0.00;[Red](#,##0.00)
        45  mm:ss
        46  [h]:mm:ss
        47  mmss.0
        48  ##0.0E+0
        49  @

        164 Start for custom formats
        --
      */
      if sNUMBERFORMAT = 'Standard' or sNUMBERFORMAT = '#,##0.00' then
        iNUMFMTID := 4;
      elsif sNUMBERFORMAT = '#,##0' then
        iNUMFMTID := 3;
      elsif sNUMBERFORMAT is not null then
        iNUMFMTID := 164 + iSTYLEID;
        cST_NUMFMTS := cST_NUMFMTS || '<numFmt numFmtId="' || to_char(iNUMFMTID) || '" formatCode="' || sNUMBERFORMAT || '"/>';
      else
        iNUMFMTID := null;
      end if;

      cST_FONTS := cST_FONTS || '<font>';
      if nFONTBOLD = 1 then
        cST_FONTS := cST_FONTS || '<b/>';
      end if;
      if nFONTITALIC = 1 then
        cST_FONTS := cST_FONTS || '<i/>';
      end if;
      cST_FONTS := cST_FONTS || '<sz val="' || nFONTSIZE || '"/>';
      cST_FONTS := cST_FONTS || '<name val="' || sFONTNAME || '"/>';

      if sFONTCOLOR is not null then
        if sFONTCOLOR like '#%' then
          cST_FONTS := cST_FONTS || '<color rgb="' || replace( sFONTCOLOR, '#', 'FF' ) || '"/>';
        elsif sFONTCOLOR like 'FF%' then
          cST_FONTS := cST_FONTS || '<color rgb="' || sFONTCOLOR || '"/>';
        else
          cST_FONTS := cST_FONTS || '<color indexed="' || sFONTCOLOR || '"/>';
        end if;
      end if;
      cST_FONTS := cST_FONTS || '</font>';

      -- Excel резервизует форматы раскраски с индексами 0 и 1
      if iSTYLEID = 0 then
        cST_FILLS := cST_FILLS || '<fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill>';
      end if;
      cST_FILLS := cST_FILLS || '<fill>';
      cST_FILLS := cST_FILLS || '<patternFill '
                   || case when sBACKCOLOR is not null then 'patternType="solid"' else 'patternType="none"' end || '>';

      if sBACKCOLOR is not null then
        cST_FILLS := cST_FILLS || '<fgColor rgb="' || replace( sBACKCOLOR, '#', 'FF' ) || '"/>';
      end if;

      cST_FILLS := cST_FILLS || '</patternFill>';
      cST_FILLS := cST_FILLS || '</fill>';

      cST_BORDERS := cST_BORDERS || '<border>';

      cST_BORDERS := cST_BORDERS || '<left '   || XLSX_DECODE_BORDERWEIGHT( nBORDERLEFTWEIGHT ) || '>';

      if sBORDERCOLOR is not null then
          if sBORDERCOLOR like '#%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || replace( sBORDERCOLOR, '#', 'FF' ) || '"/>';
          elsif sBORDERCOLOR like 'FF%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || sBORDERCOLOR || '"/>';
          else
              cST_BORDERS := '<color auto="1"/>';
          end if;
      end if;

      cST_BORDERS := cST_BORDERS || '</left>';

      cST_BORDERS := cST_BORDERS || '<right '   || XLSX_DECODE_BORDERWEIGHT( nBORDERRIGHTWEIGHT ) || '>';

      if sBORDERCOLOR is not null then
          if sBORDERCOLOR like '#%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || replace( sBORDERCOLOR, '#', 'FF' ) || '"/>';
          elsif sBORDERCOLOR like 'FF%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || sBORDERCOLOR || '"/>';
          else
              cST_BORDERS := '<color auto="1"/>';
          end if;
      end if;

      cST_BORDERS := cST_BORDERS || '</right>';

      cST_BORDERS := cST_BORDERS || '<top '   || XLSX_DECODE_BORDERWEIGHT( nBORDERTOPWEIGHT ) || '>';

      if sBORDERCOLOR is not null then
          if sBORDERCOLOR like '#%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || replace( sBORDERCOLOR, '#', 'FF' ) || '"/>';
          elsif sBORDERCOLOR like 'FF%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || sBORDERCOLOR || '"/>';
          else
              cST_BORDERS := '<color auto="1"/>';
          end if;
      end if;

      cST_BORDERS := cST_BORDERS || '</top>';

      cST_BORDERS := cST_BORDERS || '<bottom '   || XLSX_DECODE_BORDERWEIGHT( nBORDERBOTTOMWEIGHT ) || '>';

      if sBORDERCOLOR is not null then
          if sBORDERCOLOR like '#%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || replace( sBORDERCOLOR, '#', 'FF' ) || '"/>';
          elsif sBORDERCOLOR like 'FF%' then
              cST_BORDERS := cST_BORDERS || '<color rgb="' || sBORDERCOLOR || '"/>';
          else
              cST_BORDERS := '<color auto="1"/>';
          end if;
      end if;

      cST_BORDERS := cST_BORDERS || '</bottom>';

      cST_BORDERS := cST_BORDERS || '</border>';

      cST_CELLSTYLEXFS := cST_CELLSTYLEXFS || '<xf numFmtId="0" fontId="' || iSTYLEID
                                           || '" fillId="' || to_char( iSTYLEID + 2 ) || '" borderId="' || iSTYLEID ||'" '||case when sBORDERCOLOR is not null then ' applyBorder="1"' else ' applyBorder="0"' end ||'>';

      cST_CELLXFS := cST_CELLXFS || '<xf numFmtId="' || case when iNUMFMTID is null then '0' else to_char( iNUMFMTID ) end ||
                                    '" fontId="' || iSTYLEID
                                 || '" fillId="' || to_char( iSTYLEID + 2 ) || '" borderId="' || iSTYLEID || '"'||
                                  case when sBORDERCOLOR is not null then ' applyBorder="1"' else ' applyBorder="0"' end
                                 || case when nPROTECTION = 0 then ' applyProtection="1"' else null end || '>';

      cST_CELLXFS := cST_CELLXFS || '<alignment horizontal="' || lower( sHALIGNMENT ) ||
                                             '" vertical="' || lower( sVALIGNMENT ) || '" ' ||
                                             case when nTEXTROTATION  !=0 then 'textRotation="'||nTEXTROTATION||'" ' end ||
                                             case nWRAPTEXT when 1 then 'wrapText="1" ' end ||
                                             case nvl( sINDENT, '0' ) when '0' then '' else 'indent="' || sINDENT || '" ' end ||
                                             '/>';
      if nPROTECTION = 0 then
        cST_CELLXFS := cST_CELLXFS || '<protection locked="0"/>';
      end if;

      cST_CELLXFS := cST_CELLXFS || '</xf>';

      cST_CELLSTYLEXFS := cST_CELLSTYLEXFS || '<alignment horizontal="' || lower( sHALIGNMENT ) || '" vertical="' || lower( sVALIGNMENT ) || '" '
                                           ||case when nTEXTROTATION  !=0 then 'textRotation="'||nTEXTROTATION||'" ' end
                                           || case nWRAPTEXT when 1 then 'wrapText="1" ' end || '/>';
      cST_CELLSTYLEXFS := cST_CELLSTYLEXFS || '</xf>';

      cST_CELLSTYLES := cST_CELLSTYLES || '<cellStyle ' || 'name="' || nvl( sNAME, sSTYLE ) || '"'
                        || ' xfId="' || iSTYLEID || '" ' || case when iSTYLEID = 0 then 'builtinId="0" customBuiltin="1"' end || '/>';

      rSTYLEIDS( sSTYLE ) := iSTYLEID;

      iSTYLEID := iSTYLEID + 1;
    end if;
  end;

  procedure ADD_DXFS      --Объявляет формат условного форматирования
  (
    sBACKCOLOR                 in varchar2    := '#FFFFFF',-- заливка 'FFFFFF'
    sBORDERTOPSTYLE            in varchar2    := 'thin',  -- Верхняя граница ячейки (thin, dashed)
    sBORDERBOTTOMSTYLE         in varchar2    := 'thin',  -- Нижняя граница ячейки (thin, dashed)
    sBORDERLEFTSTYLE           in varchar2    := 'thin',  -- Левая граница ячейки (thin, dashed)
    sBORDERRIGHTSTYLE          in varchar2    := 'thin',  -- Правая граница ячейки (thin, dashed)
    nBORDERTOPWEIGHT           in number      := 0,       -- Верхняя граница ячейки, толщина (если 0, то не формируется)
    nBORDERBOTTOMWEIGHT        in number      := 0,       -- Нижняя граница ячейки, толщина (если 0, то не формируется)
    nBORDERLEFTWEIGHT          in number      := 0,       -- Левая граница ячейки, толщина (если 0, то не формируется)
    nBORDERRIGHTWEIGHT         in number      := 0,       -- Правая граница ячейки, толщина (если 0, то не формируется)
    nFONTBOLD                  in number      := 0,       -- Болд (0, 1)
    nFONTITALIC                in number      := 0,       -- Курсив
    sFONTCOLOR                 in varchar2    := '#000000' -- Цвет шрифта '#FFFFFF' или индексированный цвет для xlsx, см. таблицу соответствия выше
  )
  is
    iNUMFMTID                  integer;
  begin
    -- XLS-XML
    if nREPORTTYPE = 0 then
      null; --!!!
    -- XLSX
    elsif nREPORTTYPE = 1 then
      /*
        Build in ID's

        0   General
        1   0
        2   0.00
        3   #,##0
        4   #,##0.00
        9   0%
        10  0.00%
        11  0.00E+00
        12  # ?/?
        13  # ??/??
        14  mm-dd-yy
        15  d-mmm-yy
        16  d-mmm
        17  mmm-yy
        18  h:mm AM/PM
        19  h:mm:ss AM/PM
        20  h:mm
        21  h:mm:ss
        22  m/d/yy h:mm
        37  #,##0 ;(#,##0)
        38  #,##0 ;[Red](#,##0)
        39  #,##0.00;(#,##0.00)
        40  #,##0.00;[Red](#,##0.00)
        45  mm:ss
        46  [h]:mm:ss
        47  mmss.0
        48  ##0.0E+0
        49  @

        164 Start for custom formats
        --
      */

      cST_DXFS := cST_DXFS||'<dxf>';

      -- шрифт
      cST_DXFS := cST_DXFS||'<font><b val="'||nFONTBOLD||'" /><i val="'||nFONTITALIC||'" />'||
                  case when sFONTCOLOR is not null then '<color '||
                         case when sFONTCOLOR like '#%' then
                                'rgb="' || replace( sFONTCOLOR, '#', 'FF' )
                              when sFONTCOLOR like 'FF%' then
                                'rgb="' || sFONTCOLOR
                              else 'indexed="' || sFONTCOLOR
                         end ||'" />'
                       else null end ||'</font>';

      -- заливка
      if sBACKCOLOR is not null then
        cST_DXFS := cST_DXFS||'<fill><patternFill><bgColor rgb="'||replace( sBACKCOLOR, '#', 'FF' )||'" /></patternFill></fill>';
      end if;

      -- граница
      if nBORDERLEFTWEIGHT <> 0 or nBORDERRIGHTWEIGHT <> 0 or nBORDERTOPWEIGHT <> 0 or nBORDERBOTTOMWEIGHT <> 0 then
        cST_DXFS := cST_DXFS || '<border>';

        -- левая
        if nBORDERLEFTWEIGHT <> 0 then
          cST_DXFS := cST_DXFS || '<left style="'||sBORDERLEFTSTYLE||'">';
          cST_DXFS := cST_DXFS || '<color auto="1" />';
          cST_DXFS := cST_DXFS || '</left>';
        end if;

        -- правая
        if nBORDERRIGHTWEIGHT <> 0 then
          cST_DXFS := cST_DXFS || '<right style="'||sBORDERRIGHTSTYLE||'">';
          cST_DXFS := cST_DXFS || '<color auto="1" />';
          cST_DXFS := cST_DXFS || '</right>';
        end if;

        -- верхняя
        if nBORDERTOPWEIGHT <> 0 then
          cST_DXFS := cST_DXFS || '<top style="'||sBORDERTOPSTYLE||'">';
          cST_DXFS := cST_DXFS || '<color auto="1" />';
          cST_DXFS := cST_DXFS || '</top>';
        end if;

        -- нижняя
        if nBORDERBOTTOMWEIGHT <> 0 then
          cST_DXFS := cST_DXFS || '<bottom style="'||sBORDERBOTTOMSTYLE||'">';
          cST_DXFS := cST_DXFS || '<color auto="1" />';
          cST_DXFS := cST_DXFS || '</bottom>';
        end if;


        cST_DXFS := cST_DXFS || '</border>';
      end if;

      cST_DXFS := cST_DXFS||'</dxf>';

      iDXFS := iDXFS + 1;
    end if;
  end;

  procedure ADD_NAMED_RANGE
  (
    sRANGE                     in varchar2                              -- Описание региона
  )
  is
  begin
    if nCURRENTSTATE != 30 and nCURRENTSTATE != 40 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Объявлять именованные регионы надо после создания листа и друг за другом!');
    end if;
    nCURRENTSTATE := 40;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      if not lNAMESOPEN then
        PUT_LINE( '<Names>');
        nINDENT := nINDENT+1;
        lNAMESOPEN := true;
      end if;

      PUT_LINE(
                 '<NamedRange ss:Name="' || 'Print_Titles' ||
                 '" ss:RefersTo="=''' ||
                 sCURRENTSHEET || '''!' ||
                 sRANGE || '"/>'
               );
    -- XLSX
    elsif nREPORTTYPE = 1 then
      null;
    end if;
  end;

  -- Создать колонку
  procedure ADD_COLUMN
  (
    nWIDTH                     in number := 90,  -- Ширина колонки
    nAUTOFIT                   in number := 0,   -- Автоподгон ширины
    nCOUNT                     in number := 1    -- Сколько штук
  )
  is
    sAUTOFIT                   varchar2(40);
    sHIDDEN                    varchar2(40);
  begin
    if nCURRENTSTATE != 50 and nCURRENTSTATE != 60 then -- Текущее состояние
      AP_EXCEPTION(0, 'Перед описанием колонок необходимо создать таблицу с помощью OPEN_TABLE. Описывать колонки можно только после создания листа и именованных регионов (если они есть)!');
    end if;
    nCURRENTSTATE := 60;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      if nWIDTH = 0 then
        sHIDDEN := 'ss:Hidden="1" ';
      end if;

      if nvl( nAUTOFIT, 0 ) = 0 then
        sAUTOFIT := 'ss:AutoFitWidth="0" ';
      else
        sAUTOFIT := 'ss:AutoFitWidth="1" ';
      end if;

      for i in 1..nCOUNT
      loop
        PUT_LINE( '<Column ' || sHIDDEN || sAUTOFIT || 'ss:Width="' || nWIDTH || '"/>');
      end loop;

    -- XLSX
    elsif nREPORTTYPE = 1 then
      if not lCOLSOPEN then
        PUT_LINE( sCURRENTSHEET, '<cols>' );
        lCOLSOPEN := true;
      end if;

      if nAUTOFIT = 1 then
        sAUTOFIT := 'bestFit="1"';
      end if;

      -- 0.191 - эксперементально подобранный коэффициент под дефолтный стиль
      -- !!! bug если nCOUNT < 1 то выдается кривой Excel
      PUT_LINE( sCURRENTSHEET, '<col min="' || iCOLUMNID || '" max="' || to_char( iCOLUMNID + nCOUNT - 1 ) || '" '
                                 || sAUTOFIT || ' width="' || to_char( nWIDTH * 0.191, 'FM99999999999999990D00',  'NLS_NUMERIC_CHARACTERS=''. ''' ) || '" customWidth="1"/>' );
      iCOLUMNID := iCOLUMNID + nCOUNT;
    end if;

  end;

  -- базовое добавление строки
  procedure ADD_ROW_BASE
  (
    nHEIGHT                    in number := null,                      -- Высота строки
    nAUTOFIT                   in number := 0,                         -- Автоподгон высоты
    nPAGEBREAK                 in number := 0,                         -- Разрыв страницы после строки
    nSKIP                      in number := 0,                         -- Пропускать строку
    sTAG                       in varchar2 := ''                       -- Отметка (не экспортируется, сервисная информация)
  )
  as
  begin
    nROWCOUNT := nROWCOUNT + 1;
    if lOPTIMIZE_INSERT then
      vXLSROWS(vXLSROWS.Count + 1).RN := nROWCOUNT;
      vXLSROWS(vXLSROWS.Count).HEIGHT := nHEIGHT;
      vXLSROWS(vXLSROWS.Count).AUTOFIT := nAUTOFIT;
      vXLSROWS(vXLSROWS.Count).PAGEBREAK := nPAGEBREAK;
      vXLSROWS(vXLSROWS.Count).SKIP := nSKIP;
      vXLSROWS(vXLSROWS.Count).TAG := sTAG;
    else
      insert into A_XLSROWS( RN, HEIGHT, AUTOFIT, PAGEBREAK, SKIP, TAG )
        values( nROWCOUNT, nHEIGHT, nAUTOFIT, nPAGEBREAK, nSKIP, sTAG );
    end if;

    --nCOLCOUNT := 0;
  end;

  -- Добавить строку во временную таблицу
  procedure ADD_ROW
  (
    nHEIGHT                    in number := null,                      -- Высота строки
    nAUTOFIT                   in number := 0,                         -- Автоподгон высоты
    nPAGEBREAK                 in number := 0,                         -- Разрыв страницы после строки
    nSKIP                      in number := 0,                         -- Пропускать строку
    sTAG                       in varchar2 := ''                       -- Отметка (не экспортируется, сервисная информация)
  )
  is
  begin
    if nCURRENTSTATE != 60 and nCURRENTSTATE != 70 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Перед созданием строки надо описать колонки с помощью ADD_COLUMN.');
    end if;
    nCURRENTSTATE := 70;

    ADD_ROW_BASE
    (
      nHEIGHT    => nHEIGHT,
      nAUTOFIT   => nAUTOFIT,
      nPAGEBREAK => nPAGEBREAK,
      nSKIP      => nSKIP,
      sTAG       => sTAG
    );
  end;

  -- базовое добавление ячейки
  procedure ADD_CELL_BASE
  (
    sCELLDATA                  in varchar2 := '',                      -- Содержимое ячейки
    sCELLTYPE                  in varchar2 := 'Empty',                 -- Тип ячейки (Number, String, Formula, Empty)
    nROWNUMBER                 in number   := 0,                       -- Номер строки
    sSTYLE                     in varchar2 := 'Default',               -- Стиль ячейки
    nMERGEACROSS               in number   := 0,                       -- Сколько ячеек присоединить справа
    nMERGEDOWN                 in number   := 0,                       -- Сколько ячеек присоединить снизу
    nSKIP                      in number   := 0,                       -- Пропускать строку
    sTAG                       in varchar2 := '',                      -- Отметка (не экспортируется, сервисная информация)
    nWITHFORMAT                in number   := 0,                       -- Форматирование содержимого,
                                                                       -- установка флага позволяет использовать форматирование
                                                                       -- текста в ячейке
    nSKIPINDEX                 in number   := 0,                       -- Индекс ячейки (количество пропущенных столбцов)
    sCONDFORMAT                in varchar2 := '',                       -- условное форматирование
    nAUTO_EMPTY                      in number   := 0                           -- ячейка, добаленная автоматчески (пустая)
  )
  as
    nROWNUM                    number;
    nCOLNUM                    number;
begin  -- A_XLSCELLSTEST
    nROWNUM := case when nROWNUMBER = 0 then nROWCOUNT else nROWNUMBER end;
    nCOLNUM := GET_COLNUMBER_LAST( nROWNUM ) + 1;
    nCURCELL_RN := nCURCELL_RN + 1;

    if lOPTIMIZE_INSERT then
      vXLSCELLS(vXLSCELLS.Count + 1).RN := nCURCELL_RN;
      vXLSCELLS(vXLSCELLS.Count).PRN := nROWNUM;
      vXLSCELLS(vXLSCELLS.Count).STYLE := sSTYLE;
      vXLSCELLS(vXLSCELLS.Count).MERGEACROSS := nMERGEACROSS;
      vXLSCELLS(vXLSCELLS.Count).CELLDATA := sCELLDATA;
      vXLSCELLS(vXLSCELLS.Count).CELLTYPE := sCELLTYPE;
      vXLSCELLS(vXLSCELLS.Count).SKIP := nSKIP;
      vXLSCELLS(vXLSCELLS.Count).TAG := sTAG;
      vXLSCELLS(vXLSCELLS.Count).FORMATCELL := nWITHFORMAT;
      vXLSCELLS(vXLSCELLS.Count).SKIPINDEX := nSKIPINDEX;
      vXLSCELLS(vXLSCELLS.Count).MERGEDOWN := nMERGEDOWN;
      vXLSCELLS(vXLSCELLS.Count).CONDFORMAT := sCONDFORMAT;
      vXLSCELLS(vXLSCELLS.Count).AUTO_EMPTY := nAUTO_EMPTY;
      vXLSCELLS(vXLSCELLS.Count).COLNUMB := nCOLNUM;

      rNUMCOL( nROWNUM ) := nCOLNUM + nMERGEDOWN;
      rINDEX_XLSCELLS( nROWNUM||' '||nCOLNUM ) := vXLSCELLS.Count;
    else
      insert into A_XLSCELLS(RN, PRN, STYLE, MERGEACROSS, CELLDATA, CELLTYPE, SKIP, TAG, FORMATCELL, SKIPINDEX, MERGEDOWN, CONDFORMAT, COLNUMB, AUTO_EMPTY )
        values ( nCURCELL_RN, nROWNUM, sSTYLE, nMERGEACROSS, sCELLDATA, sCELLTYPE, nSKIP, sTAG, nWITHFORMAT, nSKIPINDEX, nMERGEDOWN, sCONDFORMAT, nCOLNUM, nAUTO_EMPTY );
      insert into A_XLSCELLSTEST(RN, PRN, STYLE, MERGEACROSS, CELLDATA, CELLTYPE, SKIP, TAG, FORMATCELL, SKIPINDEX, MERGEDOWN, CONDFORMAT, COLNUMB, AUTO_EMPTY )
        values ( nCURCELL_RN, nROWNUM, sSTYLE, nMERGEACROSS, sCELLDATA, sCELLTYPE, nSKIP, sTAG, nWITHFORMAT, nSKIPINDEX, nMERGEDOWN, sCONDFORMAT, nCOLNUM, nAUTO_EMPTY );
    end if;
  end;

  -- базовое обновление ячейки (!!! стиля)
  procedure UPD_CELL_BASE
  (
    nROWNUM                    in number,
    nCOLNUM                    in number,
    sSTYLE                     in varchar2  -- Стиль ячейки
  )
  as
    i                          pls_integer := 0;
  begin
    if lOPTIMIZE_INSERT then
      if vXLSCELLS.EXISTS( rINDEX_XLSCELLS( nROWNUM||' '||nCOLNUM ) ) then
        vXLSCELLS( rINDEX_XLSCELLS( nROWNUM||' '||nCOLNUM ) ).STYLE := sSTYLE;
      else
        ap_exception( 0, 'Отсутствует ячейка с номером %s', nROWNUM||' - '||nCOLNUM );
      end if;
    else
      update A_XLSCELLS c
         set c.STYLE = sSTYLE
       where c.PRN = nROWNUM
         and c.COLNUMB = nCOLNUM;

      if sql%rowcount = 0 then
        ap_exception( 0, 'Отсутствует ячейка с номером %s', nROWNUM||' - '||nCOLNUM );
      end if;
    end if;
  end;

  -- добавление пустых ячеек по кол-ву пропущенных столбцов (только для XLSX)
  procedure                    ADD_CELL_EMPTY
  (
    nCOUNT                     in number,    -- кол-во добавляемых ячеек
    nROWNUM                    in number,    -- Номер строки
    sCELLTYPE                  in varchar2,  -- Тип ячейки (Number, String, Formula, Empty)
    nSKIP                      in number,    -- Пропускать строку
    sTAG                       in varchar2,  -- Отметка (не экспортируется, сервисная информация)
    nWITHFORMAT                in number,    -- Форматирование содержимого,
                                             -- установка флага позволяет использовать форматирование
                                             -- текста в ячейке
    sCONDFORMAT                in varchar2   -- условное форматирование
  )
  as
    nCOLNUM                    number;
  begin
    if nREPORTTYPE = 0 then
      return;
    end if;

    -- добавляем пустые ячейки по кол-ву пропущенных столбцов
    for i in 1 .. nCOUNT loop
      ADD_CELL_BASE
      (
        sCELLTYPE    => sCELLTYPE,
        nROWNUMBER   => nROWNUM,
        nSKIP        => nSKIP,
        sTAG         => sTAG,
        nWITHFORMAT  => nWITHFORMAT,
        sCONDFORMAT  => sCONDFORMAT,
        nAUTO_EMPTY  => 1
      );
    end loop;
  end;

  procedure ADD_CELL
  (
    sCELLDATA                  in varchar2 := '',                      -- Содержимое ячейки
    sCELLTYPE                  in varchar2 := 'Empty',                 -- Тип ячейки (Number, String, Formula, Empty)
    nROWNUMBER                 in number   := 0,                       -- Номер строки
    sSTYLE                     in varchar2 := 'Default',               -- Стиль ячейки
    nMERGEACROSS               in number   := 0,                       -- Сколько ячеек присоединить справа
    nMERGEDOWN                 in number   := 0,                       -- Сколько ячеек присоединить снизу
    nSKIP                      in number   := 0,                       -- Пропускать строку
    sTAG                       in varchar2 := '',                      -- Отметка (не экспортируется, сервисная информация)
    nCOUNT                     in number   := 1,                       -- Сколько штук добавить
    nWITHFORMAT                in number   := 0,                       -- Форматирование содержимого,
                                                                       -- установка флага позволяет использовать форматирование
                                                                       -- текста в ячейке
    nSKIPINDEX                 in number   := 0,                       -- Индекс ячейки (количество пропущенных столбцов)
    sCONDFORMAT                in varchar2 := ''                       -- условное форматирование
 )
  is
  begin
    -- только для XLSX
    if nREPORTTYPE = 1 then
      ADD_CELL_EMPTY
      (
        nCOUNT      => nSKIPINDEX,
        nROWNUM     => nROWNUMBER,
        sCELLTYPE   => sCELLTYPE,
        nSKIP       => nSKIP,
        sTAG        => sTAG,
        nWITHFORMAT => nWITHFORMAT,
        sCONDFORMAT => sCONDFORMAT
      );
      null;
    end if;

    if nCOUNT = 1 then
      ADD_CELL_BASE
      (
        sCELLDATA    => sCELLDATA,
        sCELLTYPE    => sCELLTYPE,
        nROWNUMBER   => nROWNUMBER,
        sSTYLE       => sSTYLE,
        nMERGEACROSS => nMERGEACROSS,
        nMERGEDOWN   => nMERGEDOWN,
        nSKIP        => nSKIP,
        sTAG         => sTAG,
        nWITHFORMAT  => nWITHFORMAT,
        nSKIPINDEX   => nSKIPINDEX,
        sCONDFORMAT  => sCONDFORMAT,
        nAUTO_EMPTY  => 0
      );
    else
      for i in 1..nCOUNT
      loop
        ADD_CELL_BASE
        (
          sCELLDATA    => sCELLDATA,
          sCELLTYPE    => sCELLTYPE,
          nROWNUMBER   => nROWNUMBER,
          sSTYLE       => sSTYLE,
          nMERGEACROSS => nMERGEACROSS,
          nMERGEDOWN   => case i when 1 then nMERGEDOWN else 0 end,
          nSKIP        => nSKIP,
          sTAG         => sTAG,
          nWITHFORMAT  => nWITHFORMAT,
          nSKIPINDEX   => case i when 1 then nSKIPINDEX else 0 end,
          sCONDFORMAT  => sCONDFORMAT,
          nAUTO_EMPTY  => 0
        );
      end loop;
    end if;
  end;

 /*НОВЫЙ ФУНКЦИОНАЛ: добавление картинки "Печать с подписью" для Минздрав Сахалин. GALA*/
   procedure         ADD_DRAWING(rIMG APXWS.tARR_IMG) /*передаем коллекцию с параметрами картинок (RN записи, координаты верхней левой и нижней правой точек: COL_FROM, COL_FROM_OFF, ROW_FROM, ROW_FROM_OFF,  COL_TO, COL_TO_OFF, ROW_TO, ROW_TO_OFF)*/
   as
      Lob_loc         BLOB;
      sFILENAME       VARCHAR (255);
      nROWNUM         NUMBER;
      nCOLNUM         NUMBER;
      sEXT            VARCHAR2(10);

      type T_STR is table of number index by varchar2(10);
      ARR_IMGEXT       T_STR;
    begin
    if nREPORTTYPE = 0 then
      return;
    end if;
    nROWNUM := nROWCOUNT;
    nCOLNUM := GET_COLNUMBER_LAST( nROWNUM );

    if rIMG.COUNT > 0 then
        for I in rIMG.FIRST..rIMG.LAST
        loop
            iDRAWING := I;

            /*картинка загружена в таск-трекере */
            select TZ_DOCDATA, regexp_replace(TZ_FILENAME, '.+([.\.+$])', '\1') into Lob_loc, sEXT from APXWS.W_TASK where rn = rIMG(I).RN ;


            ADD_DRAWING_BLOB('xl/media/image'||iDRAWING||sEXT, Lob_loc);

            if not ARR_IMGEXT.EXISTS(sEXT) then
                ARR_IMGEXT(sEXT) := 1;
            end if;

          --  xl\worksheets\_rels\sheet1.xml.rels - отношения верхнего уровня
            if iDRAWING = 1 then
                sCURRENTRELSHEET := 'xl/worksheets/_rels/sheet' || iSHEETID || '.xml.rels';
                rFILES( sCURRENTRELSHEET ) := sXMLHEAD;
                PUT_LINE( sCURRENTRELSHEET, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing'||iSHEETID||'.xml"/></Relationships>' );
            end if;

          --  xl\drawings\_rels\drawing1.xml.rels - отношения верхнего уровня
            sFILENAME := 'xl/drawings/_rels/drawing' || iSHEETID || '.xml.rels';
            if iDRAWING = 1 then
                rFILES( sFILENAME ) := sXMLHEAD;
                PUT_LINE( sFILENAME, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">');
            end if;

            PUT_LINE( sFILENAME, '<Relationship Id="rId'||iDRAWING||'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/image'||iDRAWING||sEXT||'"/>' );

            if iDRAWING = rIMG.COUNT then
                PUT_LINE( sFILENAME, '</Relationships>');
            end if;

          -- xl\drawings\drawing1.xml - книга
              -- Содержит описание картинки
              sFILENAME := 'xl/drawings/drawing'||iSHEETID||'.xml';
              if iDRAWING = 1 then
                    rFILES( sFILENAME ) := sXMLHEAD;
                    PUT_LINE( sFILENAME, '<xdr:wsDr xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' );
              end if;

              PUT_LINE( sFILENAME, '<xdr:twoCellAnchor editAs="oneCell">' );

              PUT_LINE( sFILENAME, '<xdr:from><xdr:col>'||nvl(rIMG(I).nCOLFROM, nCOLNUM)||'</xdr:col><xdr:colOff>'||nvl(rIMG(I).nCOLFROM_OFF, 200025)||'</xdr:colOff><xdr:row>'||nvl(rIMG(I).nROWFROM, nROWNUM)||'</xdr:row><xdr:rowOff>'||nvl(rIMG(I).nROWFROM_OFF, 104774)||'</xdr:rowOff></xdr:from>' );
              PUT_LINE( sFILENAME, '<xdr:to><xdr:col>'||nvl(rIMG(I).nCOLTO,(nCOLNUM + 7))||'</xdr:col><xdr:colOff>'||nvl(rIMG(I).nCOLTO_OFF, 99402)||'</xdr:colOff><xdr:row>'||nvl(rIMG(I).nROWTO,(nROWNUM + 5))||'</xdr:row><xdr:rowOff>'||nvl(rIMG(I).nROWTO_OFF, 28574)||'</xdr:rowOff></xdr:to>' );

              PUT_LINE( sFILENAME, '<xdr:pic><xdr:nvPicPr><xdr:cNvPr id="'||iDRAWING||'" name="Рисунок '||iDRAWING||'"><a:extLst>');
              PUT_LINE( sFILENAME, '<a:ext uri="{FF2B5EF4-FFF2-40B4-BE49-F238E27FC236}">');
              PUT_LINE( sFILENAME, '<a16:creationId xmlns:a16="http://schemas.microsoft.com/office/drawing/2014/main" id="{5C21FFDD-3647-4632-A6AD-F92289B3BF77}"/>');
              PUT_LINE( sFILENAME, '</a:ext></a:extLst></xdr:cNvPr><xdr:cNvPicPr><a:picLocks noChangeAspect="1"/></xdr:cNvPicPr></xdr:nvPicPr>');
              PUT_LINE( sFILENAME, '<xdr:blipFill><a:blip xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:embed="rId'||iDRAWING||'" cstate="print"><a:extLst><a:ext uri="{28A0092B-C50C-407E-A947-70E740481C1C}">');
              PUT_LINE( sFILENAME, '<a14:useLocalDpi xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" val="0"/></a:ext></a:extLst></a:blip><a:stretch><a:fillRect/></a:stretch></xdr:blipFill>');
              PUT_LINE( sFILENAME, '<xdr:spPr><a:xfrm><a:off x="2838450" y="10925176"/><a:ext cx="2176055" cy="1666900"/></a:xfrm>');
              PUT_LINE( sFILENAME, '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></xdr:spPr></xdr:pic><xdr:clientData/></xdr:twoCellAnchor>');

              if iDRAWING = rIMG.COUNT then
                PUT_LINE( sFILENAME, '</xdr:wsDr>' );
              end if;
        end loop;

        sEXT := ARR_IMGEXT.FIRST;
        loop
        exit when sEXT is null;
            PUT_LINE( '[Content_Types].xml', '<Default ContentType="image/'||SUBSTR(sEXT, 2)||'" Extension="'||SUBSTR(sEXT, 2)||'"/>' );
            sEXT := ARR_IMGEXT.NEXT(sEXT);
        end loop;

        PUT_LINE( '[Content_Types].xml', '<Override ContentType="application/vnd.openxmlformats-officedocument.drawing+xml" PartName="/xl/drawings/drawing'||iSHEETID||'.xml"/>' );

    end if;
    end;

  -- добавить колонтитул
  -- *** XML
  -- пример: '&amp;&quot;Vani,полужирный&quot;&amp;18&amp;Ч&amp;З&amp;Рпростой текст&#10;&amp;С'
  -- экранировать простой текст не нужно, передаем: 'простой текст'
  -- любой формат передается с экранированием через "&amp;"
  -- шрифт и начертание (&quot;Vani,полужирный&quot;) (обычный, курсив, полужирный, полужирный курсив)
  -- размер шрифта
  -- подчеркивание (Ч - одинарное по значению, Й - двойное по значению)
  -- видоизменение (З - зачеркнутый, Р - надстрочечный, И - подстрочный )
  -- спец символ &#10; - переход на новую строку
  -- С - номер страницы
  -- К - кол-во страниц
  -- Д - дата
  -- В - время
  -- Ь - Путь
  -- Ф - файл
  -- Я - лист
  -- *** XLSX
  -- пример: '&amp;"Vani,обычный"&amp;10&amp;U&amp;K995555простой текст'
  -- тоже самое, что для XML, немного отличаются форматы. ДАЛЕЕ УКАЗАНЫ РАЗЛИЧИЯ
  -- шрифт и начертание ("Vani,обычный")
  -- подчеркивание (U - одинарное по значению, E - двойное по значению)
  -- видоизменение (S - зачеркнутый, X - надстрочечный, Y - подстрочный )
  -- цвет K000000
  -- P - номер страницы
  -- N - кол-во страниц
  -- D - дата
  -- T - время
  -- Z - Путь
  -- F - файл
  -- A - лист
  procedure ADD_RUNTITLE
  (
    sHEADERLEFT                    in varchar2 := '', -- верхний левый
    sHEADERCENTER                  in varchar2 := '', -- верхний центр
    sHEADERRIGTH                   in varchar2 := '', -- верхний правый
    sFOOTERLEFT                    in varchar2 := '', -- нижний левый
    sFOOTERCENTER                  in varchar2 := '', -- нижний центр
    sFOOTERRIGTH                   in varchar2 := ''  -- нижний правый
  )
  as
  begin
    -- !!! должен быть на открытом листе, проверить состояние

    -- *** XLS-XML
    if nREPORTTYPE = 0 then
      -- верх
      if sHEADERLEFT is not null or sHEADERCENTER is not null or sHEADERRIGTH is not null then
        сST_RUNTITLE := '<Header x:Margin="0.1" x:Data="';

        -- лево
        if sHEADERLEFT is not null then
          сST_RUNTITLE := сST_RUNTITLE||'&amp;Л'||sHEADERLEFT;
        end if;
        -- центр
        if sHEADERCENTER is not null then
          сST_RUNTITLE := сST_RUNTITLE||'&amp;Ц'||sHEADERCENTER;
        end if;
        -- право
        if sHEADERRIGTH is not null then
          сST_RUNTITLE := сST_RUNTITLE||'&amp;П'||sHEADERRIGTH;
        end if;

        сST_RUNTITLE := сST_RUNTITLE||'" x:Horizontal="Right"/>';
      end if;

      -- низ
      if sFOOTERLEFT is not null or sFOOTERCENTER is not null or sFOOTERRIGTH is not null then
        сST_RUNTITLE := '<Footer x:Margin="0.31496062992125984" x:Data="';

        -- лево
        if sFOOTERLEFT is not null then
          сST_RUNTITLE := сST_RUNTITLE||'&amp;Л'||sFOOTERLEFT;
        end if;
        -- центр
        if sFOOTERCENTER is not null then
          сST_RUNTITLE := сST_RUNTITLE||'&amp;Ц'||sFOOTERCENTER;
        end if;
        -- право
        if sFOOTERRIGTH is not null then
          сST_RUNTITLE := сST_RUNTITLE||'&amp;П'||sFOOTERRIGTH;
        end if;

        сST_RUNTITLE := сST_RUNTITLE||'"/>';
      end if;

    -- *** XLSX
    else
      if sHEADERLEFT is not null or sHEADERCENTER is not null or sHEADERRIGTH is not null or
         sFOOTERLEFT is not null or sFOOTERCENTER is not null or sFOOTERRIGTH is not null then
        сST_RUNTITLE := '<headerFooter>';

        -- верх
        if sHEADERLEFT is not null or sHEADERCENTER is not null or sHEADERRIGTH is not null then
          сST_RUNTITLE := сST_RUNTITLE||'<oddHeader>';

          -- лево
          if sHEADERLEFT is not null then
            сST_RUNTITLE := сST_RUNTITLE||'&amp;L'||sHEADERLEFT;
          end if;
          -- центр
          if sHEADERCENTER is not null then
            сST_RUNTITLE := сST_RUNTITLE||'&amp;C'||sHEADERCENTER;
          end if;
          -- право
          if sHEADERRIGTH is not null then
            сST_RUNTITLE := сST_RUNTITLE||'&amp;R'||sHEADERRIGTH;
          end if;

          сST_RUNTITLE := сST_RUNTITLE||'</oddHeader>';
        end if;

        -- низ
        if sFOOTERLEFT is not null or sFOOTERCENTER is not null or sFOOTERRIGTH is not null then
          сST_RUNTITLE := сST_RUNTITLE||'<oddFooter>';

          -- лево
          if sFOOTERLEFT is not null then
            сST_RUNTITLE := сST_RUNTITLE||'&amp;L'||sFOOTERLEFT;
          end if;
          -- центр
          if sFOOTERCENTER is not null then
            сST_RUNTITLE := сST_RUNTITLE||'&amp;C'||sFOOTERCENTER;
          end if;
          -- право
          if sFOOTERRIGTH is not null then
            сST_RUNTITLE := сST_RUNTITLE||'&amp;R'||sFOOTERRIGTH;
          end if;

          сST_RUNTITLE := сST_RUNTITLE||'</oddFooter>';
        end if;

        сST_RUNTITLE := сST_RUNTITLE||'</headerFooter>';

      end if;
    end if;
  end;

  -- *** XML условное форматирование
  -- !!! для одной ячейки может применяться только 1 форматирование
  -- !!! в одном усл.форматировании может быть до 3 условий
  -- !!! при пересечении условий применение по приоритету, т.е. условие1, условие2, условие3
  -- если условие не задано, то это условие - "формула", задается в "значении 1"
  -- "значение 2" задается только для условия "значение" с типом ВНЕ и МЕЖДУ
  -- условия "значение":
  -- Between        - МЕЖДУ
  -- NotBetween     - ВНЕ
  -- Equal          - РАВНО
  -- NotEqual       - НЕ РАВНО
  -- Greater        - БОЛЬШЕ
  -- Less           - МЕНЬШЕ
  -- GreaterOrEqual - БОЛЬШЕ ИЛИ РАВНО
  -- LessOrEqual    - МЕНЬШЕ ИЛИ РАВНО
  -- формат -  'font-style:italic;font-weight:400;text-line-through:single;
  --            border:.5pt solid windowtext;background:lime'
  procedure ADD_CONDFORMAT_XML
  (
    sCONDFORMAT                  in varchar2,       -- имя условного форматирования
    -- условие 1
    sQUALIFIER                   in varchar2 := '', -- условие (для формулы не задается)
    sVALUE1                      in varchar2,       -- значение 1
    sVALUE2                      in varchar2 := '', -- значение 2 (только для условий ВНЕ и МЕЖДУ)
    sFORMAT                      in varchar2 := '', -- формат
    -- условие 2
    sQUALIFIER_2                 in varchar2 := '', -- условие (для формулы не задается)
    sVALUE1_2                    in varchar2 := '', -- значение 1 (обязательно, если нужно 2 условие)
    sVALUE2_2                    in varchar2 := '', -- значение 2 (только для условий ВНЕ и МЕЖДУ)
    sFORMAT_2                    in varchar2 := '', -- формат
    -- условие 3
    sQUALIFIER_3                 in varchar2 := '', -- условие (для формулы не задается)
    sVALUE1_3                    in varchar2 := '', -- значение 1 (обязательно, если нужно 3 условие)
    sVALUE2_3                    in varchar2 := '', -- значение 2 (только для условий ВНЕ и МЕЖДУ)
    sFORMAT_3                    in varchar2 := ''  -- формат
  )
  as
    -- добавить условие
    procedure ADD_CONDITION
    (
      sQUAL                      in varchar2 := '',
      sVAL1                      in varchar2,
      sVAL2                      in varchar2 := '',
      sFORM                      in varchar2 := '',
      nCONDITION                 in number,
      cCONDFORMAT                in out clob
    )
    as
    begin
      cCONDFORMAT := cCONDFORMAT||'<Condition>';
      if sQUAL is not null then
        cCONDFORMAT := cCONDFORMAT||'<Qualifier>'||sQUAL||'</Qualifier>';

        if sQUAL in ( 'Between', 'NotBetween' ) then
          if sVAL2 is null then
            ap_exception( 0, 'Для условного форматирования "%s" нужно указать "значение 2". Условие %s', sCONDFORMAT, nCONDITION );
          end if;
        else
          if sVAL2 is not null then
            ap_exception( 0, 'Для условного форматирования "%s" не нужно указывать "значение 2". Условие %s"', sCONDFORMAT, nCONDITION );
          end if;
        end if;
      end if;

      cCONDFORMAT := cCONDFORMAT||'<Value1>'||sVAL1||'</Value1>';

      if sVAL2 is not null then
        cCONDFORMAT := cCONDFORMAT||'<Value2>'||sVAL2||'</Value2>';
      end if;

      if sFORM is not null then
        cCONDFORMAT := cCONDFORMAT||'<Format Style='''||sFORM||'''/>';
      end if;

      cCONDFORMAT := cCONDFORMAT||'</Condition>';
    end;

  begin
    -- !!! проверить состояние

    -- *** XLS-XML
    if nREPORTTYPE = 0 then
      cST_CONDFORMAT := '<ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">';
      cST_CONDFORMAT := cST_CONDFORMAT||'<Range>##RANGE##</Range>'; -- !!! делать замену на имена ячеек

      -- условие 1
      ADD_CONDITION( sQUALIFIER, sVALUE1, sVALUE2, sFORMAT, 1, cST_CONDFORMAT );
      -- условие 2
      if sVALUE1_2 is not null then
        ADD_CONDITION( sQUALIFIER_2, sVALUE1_2, sVALUE2_2, sFORMAT_2, 2, cST_CONDFORMAT );
      end if;
      -- условие 3
      if sVALUE1_3 is not null then
        ADD_CONDITION( sQUALIFIER_3, sVALUE1_3, sVALUE2_3, sFORMAT_3, 3, cST_CONDFORMAT );
      end if;

      cST_CONDFORMAT := cST_CONDFORMAT||'</ConditionalFormatting>';

    -- *** XLSX
    else
      ap_exception( 0, 'В процедуре ADD_CONDFORMAT_XML не реализовано условное форматирование для формата XLSX. Вызовите процедуру ADD_CONDFORMAT_XLSX!' );
    end if;

    rCONDFORMAT( sCONDFORMAT ) := cST_CONDFORMAT;
  end;

  -- *** XLSX условное форматирование
  -- !!! приоритетность по порядку добавления
  -- !!! для одной ячейки может применяться несколько способов форматирования (реализовано только одно!!!)
  -- !!! при пересечении условий применение по приоритету в порядке объявления
  -- !!! условное форматирование не применяется, если применяется стиль (стиль в приоритете - проверить) !!!

  -- тип условного форматирования:
  -- colorScale - цветовая шкала (двухцветная/трехцветная)
  -- cellIs     - ячейки, которые содержат
  -- *******************  colorScale **************************
  -- тип шкалы минильного/среднего/максимального значения:
  -- min     - минимальное значение (только для минимальных значений)
  -- max     - максимальное значение (только для максимальных значений)
  -- num     - число
  -- percent - процент
  -- formula - формула
  -- percentile - процентвиль
  -- *******************  cellIs **************************
  -- операции: значения ячейки
  -- between            - между
  -- notBetween         - вне
  -- equal              - равно
  -- notEqual           - не равно
  -- greaterThan        - больше
  -- lessThan           - меньше
  -- greaterThanOrEqual - больше или равно
  -- lessThanOrEqual    - меньше или равно

  procedure ADD_CONDFORMAT_XLSX
  (
    sCONDFORMAT                  in varchar2,       -- имя условного форматирования
    sCONDTYPE                    in varchar2,       -- тип условного форматирования
    -- цветовая шкала - минимальное значение
    sCSCALE_MINTYPE              in varchar2 := '', -- тип
    sCSCALE_MINVALUE             in varchar2 := '', -- значение (не указывается для типа "минимальное значение")
    sCSCALE_MINCOLOR             in varchar2 := '', -- цвет
    -- цветовая шкала - среднее значение (для трехцветной шкалы)
    sCSCALE_AVGTYPE              in varchar2 := '', -- тип
    sCSCALE_AVGVALUE             in varchar2 := '', -- значение
    sCSCALE_AVGCOLOR             in varchar2 := '', -- цвет
    -- цветовая шкала - максимальное значение
    sCSCALE_MAXTYPE              in varchar2 := '', -- тип
    sCSCALE_MAXVALUE             in varchar2 := '', -- значение (не указывается для типа "максимальное значение")
    sCSCALE_MAXCOLOR             in varchar2 := '', -- цвет
    ---------------------------------------------------------------------------------
    sOPERATOR                    in varchar2 := '', -- операция
    sVALUE1                      in varchar2 := '',
    sVALUE2                      in varchar2 := '',
    -- формат для "ячейки, которые содержат"
    sBACKCOLOR                   in varchar2    := '#FFFFFF',-- заливка 'FFFFFF'
    sBORDERTOPSTYLE              in varchar2    := 'thin',  -- Верхняя граница ячейки (thin, dashed)
    sBORDERBOTTOMSTYLE           in varchar2    := 'thin',  -- Нижняя граница ячейки (thin, dashed)
    sBORDERLEFTSTYLE             in varchar2    := 'thin',  -- Левая граница ячейки (thin, dashed)
    sBORDERRIGHTSTYLE            in varchar2    := 'thin',  -- Правая граница ячейки (thin, dashed)
    nBORDERTOPWEIGHT             in number      := 0,       -- Верхняя граница ячейки, толщина (если 0, то не формируется)
    nBORDERBOTTOMWEIGHT          in number      := 0,       -- Нижняя граница ячейки, толщина (если 0, то не формируется)
    nBORDERLEFTWEIGHT            in number      := 0,       -- Левая граница ячейки, толщина (если 0, то не формируется)
    nBORDERRIGHTWEIGHT           in number      := 0,       -- Правая граница ячейки, толщина (если 0, то не формируется)
    nFONTBOLD                    in number      := 0,       -- Болд (0, 1)
    nFONTITALIC                  in number      := 0,       -- Курсив
    sFONTCOLOR                   in varchar2    := '#000000' -- Цвет шрифта '#FFFFFF' или индексированный цвет для xlsx, см. таблицу соответствия выше
  )
  as
  begin
    -- !!! проверить состояние

    -- *** XLS-XML
    if nREPORTTYPE = 0 then
      ap_exception( 0, 'В процедуре ADD_CONDFORMAT_XLSX не реализовано условное форматирование для формата XML. Вызовите процедуру ADD_CONDFORMAT_XML!' );

    -- *** XLSX
    else
      cST_CONDFORMAT := '<conditionalFormatting sqref="##RANGE##">';

      -- цветовая шкала (двухцветная, трехцветная)
      if trim( sCONDTYPE ) = 'colorScale' then
        cST_CONDFORMAT := cST_CONDFORMAT||'<cfRule type="'||trim( sCONDTYPE )||'" priority="'||to_char( nPRIORITY )||'">';

        -- проверки
        -- минимальное значение
        if trim( sCSCALE_MINTYPE ) not in ( 'min', 'num', 'percent', 'formula', 'percentile' ) then
          ap_exception( 0, 'Для цветовой шкалы минимального значения тип "%s" указан некорректно! Форматирование "%s"', trim( sCSCALE_MINTYPE ), sCONDFORMAT );

        elsif trim( sCSCALE_MINTYPE ) = 'min' and sCSCALE_MINVALUE is not null then
          ap_exception( 0, 'Для цветовой шкалы минимального значения тип "min" не нужно указывать "значение"! Форматирование "%s"', sCONDFORMAT );

        elsif trim( sCSCALE_MINTYPE ) in ( 'num', 'percent', 'formula', 'percentile' ) and sCSCALE_MINVALUE is null then
          ap_exception( 0, 'Для цветовой шкалы минимального значения тип "%s" нужно указать "значение"! Форматирование "%s"', trim( sCSCALE_MINTYPE ), sCONDFORMAT );

        elsif trim( sCSCALE_MINTYPE ) in ( 'percent', 'percentile' ) and to_number( sCSCALE_MINVALUE ) > 100 then
          ap_exception( 0, 'Для цветовой шкалы минимального значения тип "%s" некорректно задание "значения" "%s"! Форматирование "%s"', trim( sCSCALE_MINTYPE ), sCSCALE_MINVALUE, sCONDFORMAT );

        elsif sCSCALE_MINCOLOR is null then
          ap_exception( 0, 'Для цветовой шкалы минимального значения нужно указать "цвет"! Форматирование "%s"', sCONDFORMAT );
        end if;

        -- среднее значение
        if sCSCALE_AVGTYPE is not null or sCSCALE_AVGVALUE is not null or sCSCALE_AVGCOLOR is not null then
          if trim( sCSCALE_AVGTYPE ) not in ( 'num', 'percent', 'formula', 'percentile' ) then
            ap_exception( 0, 'Для цветовой шкалы среднего значения тип "%s" указан некорректно! Форматирование "%s"', trim( sCSCALE_AVGTYPE ), sCONDFORMAT );

          elsif sCSCALE_AVGVALUE is null then
            ap_exception( 0, 'Для цветовой шкалы среднего значения нужно указать "значение"! Форматирование "%s"', trim( sCSCALE_AVGTYPE ), sCONDFORMAT );

          elsif trim( sCSCALE_AVGTYPE ) in ( 'percent', 'percentile' ) and to_number( sCSCALE_AVGVALUE ) > 100 then
            ap_exception( 0, 'Для цветовой шкалы среднего значения тип "%s" некорректно задание "значения" "%s"! Форматирование "%s"', trim( sCSCALE_AVGTYPE ), sCSCALE_AVGVALUE, sCONDFORMAT );

          elsif sCSCALE_AVGCOLOR is null then
            ap_exception( 0, 'Для цветовой шкалы среднего значения нужно указать "цвет"! Форматирование "%s"', sCONDFORMAT );
          end if;
        end if;

        -- максимальное значение
        if trim( sCSCALE_MAXTYPE ) not in ( 'max', 'num', 'percent', 'formula', 'percentile' ) then
          ap_exception( 0, 'Для цветовой шкалы максимального значения тип "%s" указан некорректно! Форматирование "%s"', trim( sCSCALE_MAXTYPE ), sCONDFORMAT );

        elsif trim( sCSCALE_MAXTYPE ) = 'max' and sCSCALE_MAXVALUE is not null then
          ap_exception( 0, 'Для цветовой шкалы максимального значения тип "max" не нужно указывать "значение"! Форматирование "%s"', sCONDFORMAT );

        elsif trim( sCSCALE_MAXTYPE ) in ( 'num', 'percent', 'formula', 'percentile' ) and sCSCALE_MAXVALUE is null then
          ap_exception( 0, 'Для цветовой шкалы максимального значения тип "%s" нужно указать "значение"! Форматирование "%s"', trim( sCSCALE_MAXTYPE ), sCONDFORMAT );

        elsif trim( sCSCALE_MAXTYPE ) in ( 'percent', 'percentile' ) and to_number( sCSCALE_MAXVALUE ) > 100 then
          ap_exception( 0, 'Для цветовой шкалы среднего значения тип "%s" некорректно задание "значения" "%s"! Форматирование "%s"', trim( sCSCALE_MAXTYPE ), sCSCALE_MAXVALUE, sCONDFORMAT );

        elsif sCSCALE_MAXCOLOR is null then
          ap_exception( 0, 'Для цветовой шкалы максимального значения нужно указать "цвет"! Форматирование "%s"', sCONDFORMAT );
        end if;

        ------------------------------------------------------------------------------
        cST_CONDFORMAT := cST_CONDFORMAT||'<colorScale>';

        -- значения
        -- минимальное значение
        cST_CONDFORMAT := cST_CONDFORMAT||'<cfvo type="'||trim( sCSCALE_MINTYPE )||'" '||
                          case when trim( sCSCALE_MINTYPE ) <> 'min' then 'val="'||sCSCALE_MINVALUE||'" ' else null end ||'/>';

        -- среднее значение
        if sCSCALE_AVGTYPE is not null and sCSCALE_AVGVALUE is not null and sCSCALE_AVGCOLOR is not null then
          cST_CONDFORMAT := cST_CONDFORMAT||'<cfvo type="'||trim( sCSCALE_AVGTYPE )||'" val="'||sCSCALE_AVGVALUE||'" />';
        end if;

        -- максимальное значение
        cST_CONDFORMAT := cST_CONDFORMAT||'<cfvo type="'||trim( sCSCALE_MAXTYPE )||'" '||
                          case when trim( sCSCALE_MAXTYPE ) <> 'max' then 'val="'||sCSCALE_MAXVALUE||'" ' else null end ||'/>';

        -- цвета
        cST_CONDFORMAT := cST_CONDFORMAT||'<color rgb="'||replace( sCSCALE_MINCOLOR, '#', 'FF' )||'" />';
        if sCSCALE_AVGTYPE is not null and sCSCALE_AVGVALUE is not null and sCSCALE_AVGCOLOR is not null then
          cST_CONDFORMAT := cST_CONDFORMAT||'<color rgb="'||replace( sCSCALE_AVGCOLOR, '#', 'FF' )||'" />';
        end if;
        cST_CONDFORMAT := cST_CONDFORMAT||'<color rgb="'||replace( sCSCALE_MAXCOLOR, '#', 'FF' )||'" />';

        cST_CONDFORMAT := cST_CONDFORMAT||'</colorScale>';

      -- *** форматирование ячеек, которые содержат
      elsif trim( sCONDTYPE ) = 'cellIs' then
        -- проверки
        if sOPERATOR in ( 'between', 'notBetween' ) then
          if sVALUE2 is null then
            ap_exception( 0, 'Для условного форматирования "%s" нужно указать "значение 2". Условие %s', sCONDFORMAT, sOPERATOR );
          end if;
        else
          if sVALUE2 is not null then
            ap_exception( 0, 'Для условного форматирования "%s" не нужно указывать "значение 2". Условие %s"', sCONDFORMAT, sOPERATOR );
          end if;
        end if;

        -- добавление формата
        ADD_DXFS
        (
          sBACKCOLOR           => sBACKCOLOR,
          sBORDERTOPSTYLE      => sBORDERTOPSTYLE,
          sBORDERBOTTOMSTYLE   => sBORDERBOTTOMSTYLE,
          sBORDERLEFTSTYLE     => sBORDERLEFTSTYLE,
          sBORDERRIGHTSTYLE    => sBORDERRIGHTSTYLE,
          nBORDERTOPWEIGHT     => nBORDERTOPWEIGHT,
          nBORDERBOTTOMWEIGHT  => nBORDERBOTTOMWEIGHT,
          nBORDERLEFTWEIGHT    => nBORDERLEFTWEIGHT,
          nBORDERRIGHTWEIGHT   => nBORDERRIGHTWEIGHT,
          nFONTBOLD            => nFONTBOLD,
          nFONTITALIC          => nFONTITALIC,
          sFONTCOLOR           => sFONTCOLOR
        );

        cST_CONDFORMAT := cST_CONDFORMAT||'<cfRule type="'||trim( sCONDTYPE )||'" dxfId="'||to_char( iDXFS - 1 )||
                                          '" priority="'||to_char( nPRIORITY )||'" operator="'||sOPERATOR||'">';

        cST_CONDFORMAT := cST_CONDFORMAT||'<formula>'||to_char( sVALUE1 )||'</formula>';

        if sVALUE2 is not null then
          cST_CONDFORMAT := cST_CONDFORMAT||'<formula>'||to_char( sVALUE2 )||'</formula>';
        end if;

      else
        ap_exception( 0, 'Неизвестный тип формирования "%s"! Форматирование "%s"', sCONDTYPE, sCONDFORMAT );
      end if;

      cST_CONDFORMAT := cST_CONDFORMAT||'</cfRule>';
      cST_CONDFORMAT := cST_CONDFORMAT||'</conditionalFormatting>';

    end if;

    nPRIORITY := nPRIORITY + 1;
    rCONDFORMAT( sCONDFORMAT ) := cST_CONDFORMAT;
  end;


  -- Преобразование относительной формулы в абсолютную
  --  =R[-1]C[-2]*RC[-1] в A1*B2
  function VALIDATE_FORMULA
  (
    sFORMULA                     in varchar2,
    nCURRENT_ROW                 in number,
    nCURRENT_COL                 in number
  )
  return varchar2
  is
    i                            integer := 1;
    sFORMULA_RES                 varchar2(4000);
    sADDRESS                     varchar2(4000); -- Текст ссылки на ячейку (буфер с текущим адресом)
    sSYMBOL                      varchar2(1);
    sNEXT_SYMBOL                 varchar2(1);
    bIS_ADDR                     boolean := false; -- Текущий символ принадлежит адресу
    bIS_ADDR_ROW                 boolean := false; -- Текущий символ принадлежит строке адреса
    bIS_ADDR_COL                 boolean := false; -- Текущий символ принадлежит колонке адреса
    bIS_ADDR_END                 boolean := false; -- Конец адреса

    sROW_PART                    varchar2(4000);   -- Отступ по строкам
    sCOL_PART                    varchar2(4000);   -- Отступ по колонкам

    nROW_PART                    integer;
    nCOL_PART                    integer;
  begin
    if sFORMULA is null then
      AP_EXCEPTION( 0, 'Для ячейки "%s%s" необходимо указать формулу.', GET_COL_NAME(nCURRENT_COL), to_char(nCURRENT_ROW) );
    end if;

    for i in 1..length( sFORMULA ) + 1 -- +1, чтобы заполнять последнюю ссылку
    loop
      sSYMBOL := substr( sFORMULA, i, 1 );

      -- Стартовое равно пропускаем
      if i=1 and sSYMBOL = '=' then
        continue;
      end if;

      -- Гипотетическое начало ссылки
      if sSYMBOL = 'R' and not bIS_ADDR then
        bIS_ADDR := true;
      end if;

      -- Ожидаемый символ входит в ссылку
      if bIS_ADDR then
        if sSYMBOL = 'R' then
          bIS_ADDR_ROW := true;
          bIS_ADDR_COL := false;
          bIS_ADDR_END := false;

          -- Если началась новая формула, а у нас в буфере что-то лежит
          -- выпишнем все это в формулу
          if sADDRESS is not null then
            sFORMULA_RES := sFORMULA_RES || sADDRESS;
            sADDRESS := '';
          end if;
        end if;

        sADDRESS := sADDRESS || sSYMBOL;

        -- Обрабатывается ссылка на строку
        if bIS_ADDR_ROW then
          -- Перебираем возможные варианты окончания строки
          if sSYMBOL in ( 'R', '[', ']', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ) then
            -- Все возможные варианты
            sROW_PART := sROW_PART || sSYMBOL;
          elsif sSYMBOL = 'C' then
            -- Конец
            bIS_ADDR_ROW := false;
            bIS_ADDR_COL := true;
          else
            -- Все ошибка
            sROW_PART := '';
            bIS_ADDR := false;
            bIS_ADDR_ROW := false;
          end if;
        end if;

        if bIS_ADDR_COL then
          -- Перебираем возможные варианты окончания строки
          if sSYMBOL = 'C' then
            -- За первым символом может не идти интервала, тогда считаем, что на это всё заканчивается
            sNEXT_SYMBOL := substr( sFORMULA, i + 1, 1 );
            if nvl( sNEXT_SYMBOL, 'x' ) != '[' then
              bIS_ADDR_END := true;
            end if;

            sCOL_PART := sCOL_PART || sSYMBOL;
          elsif sSYMBOL in ( '[', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ) and not bIS_ADDR_END then
            -- Все возможные варианты
            sCOL_PART := sCOL_PART || sSYMBOL;
          elsif sSYMBOL = ']' then
            bIS_ADDR_END := true;
            sCOL_PART := sCOL_PART || sSYMBOL;
          elsif bIS_ADDR_END then
            -- Формируем, полученный результат
            if sROW_PART = 'R' then
              nROW_PART := nCURRENT_ROW;
            elsif regexp_like( sROW_PART, '^R\[-{0,1}\d+\]$' ) then
              nROW_PART := nCURRENT_ROW + to_number( regexp_substr( sROW_PART, '-{0,1}\d+' ) );
            else
              nROW_PART := null;
            end if;

            if sCOL_PART = 'C' then
              nCOL_PART := nCURRENT_COL;
            elsif regexp_like( sCOL_PART, '^C\[-{0,1}\d+\]$' ) then
              nCOL_PART := nCURRENT_COL + to_number( regexp_substr( sCOL_PART, '-{0,1}\d+\' ) );
            else
              nCOL_PART := null;
            end if;

            -- Если все срослось, то подменяем формулу из буфера
            if nROW_PART is not null and nCOL_PART is not null and
              nCOL_PART > 0 and
              nROW_PART > 0 then
              sADDRESS := GET_COL_NAME( nCOL_PART );
              sADDRESS := sADDRESS || to_char( nROW_PART );

              -- Не забыдем прицепить символ за адресом
              sADDRESS := sADDRESS || sSYMBOL;
            end if;

            sROW_PART := '';
            sCOL_PART := '';
            bIS_ADDR := false;
            bIS_ADDR_COL := false;
            bIS_ADDR_END := false;
          else
            -- Все ошибка
            sCOL_PART := '';
            bIS_ADDR := false;
            bIS_ADDR_COL := false;
          end if;
        end if;
      else
        sFORMULA_RES := sFORMULA_RES || sADDRESS || sSYMBOL;
        sADDRESS := '';
      end if;
    end loop;

    -- Закрепим последнюю формулу, если она есть в буфере
    sFORMULA_RES := sFORMULA_RES || sADDRESS;

    return sFORMULA_RES;
  end;

  procedure FLUSH_ROWCELLS
  (
    bMARGINBOTTOM         in varchar  default '0.4',
    bMARGINLEFT           in varchar  default '0.4',
    bMARGINRIGHT          in varchar  default '0.4',
    bMARGINTOP            in varchar  default '0.4'
  )
  is
    nCELLINDEX                   number;

    cMERGE                       clob;
    sMERGE                       varchar2(32767);
    cPAGEBREAK                   clob;
    sCELL                        varchar2(32767);
    sDECIMAL                     varchar2(10);
    iCOLNUMBER                   integer;
    nBREAK_CNT                   integer;
    cCLOBXLS                     clob;
    nEXISTS                      integer;
    lMERGEDOWN                   boolean := false;

    -- Добавление строки в файл-буфер (XLSX)
    procedure PUT_LINEXLSX
    (
      sVALUE          in varchar2
    )
    is
      sCLOBVALUE      varchar2( 32767 );
    begin
      sCLOBVALUE := sVALUE || sCR;
      DBMS_LOB.writeappend( cCLOBXLS, length( sCLOBVALUE ), sCLOBVALUE );
    end;

  begin
    if nCURRENTSTATE != 70 then                    -- Текущее состояние
      AP_EXCEPTION(0, 'Перед выгрузкой строк и ячеек их надо предварительно создать с помощью ADD_ROW и ADD_CELL.');
    end if;
    nCURRENTSTATE := 80;

    begin
      Select substr(VALUE, 1, 1)
        into sDECIMAL
        from NLS_SESSION_PARAMETERS
       where PARAMETER = 'NLS_NUMERIC_CHARACTERS';
    exception
      when NO_DATA_FOUND then
        sDECIMAL := '.';
    end;

    if lOPTIMIZE_INSERT then
      forall i in 1..vXLSROWS.count
       insert into A_XLSROWS values vXLSROWS(i);

      forall i in 1..vXLSCELLS.count
       insert into A_XLSCELLS values vXLSCELLS(i);
    end if;

    -- XLS-XML
    if nREPORTTYPE = 0 then
      for cur_rows in
      (
        select r.RN, r.HEIGHT, r.AUTOFIT
          from A_XLSROWS r
         where r.SKIP=0
         order by r.RN
      )
      loop
        PUT_LINE( '<Row ss:Index="' || cur_rows.RN || '"' || case when cur_rows.HEIGHT is not null then ' ss:Height="' || cur_rows.HEIGHT || '" ' end || case when cur_rows.autofit!=0 then ' ss:AutoFitHeight="1"' end || '>');
        nINDENT := nINDENT + 1;
        nCELLINDEX := 0;

        for cur_cells in
        (
          select c.STYLE,
                 c.CELLDATA,
                 c.CELLTYPE,
                 c.MERGEACROSS,
                 c.MERGEDOWN,
                 c.FORMATCELL,
                 c.SKIPINDEX
            from A_XLSCELLS c
           where c.PRN = cur_rows.RN
             and c.SKIP = 0
           order by c.RN
        )
        loop
          if cur_cells.CELLTYPE = 'Number' then
            cur_cells.CELLDATA := replace(cur_cells.CELLDATA, sDecimal, '.');
          end if;

          nCELLINDEX := nCELLINDEX + 1 + nvl( cur_cells.SKIPINDEX, 0 );

          sCELL := '<Cell ss:StyleID="'||cur_cells.STYLE||'"' ||
            case
              when cur_cells.SKIPINDEX != 0 then ' ss:Index="' || nCELLINDEX || '"'
            end ||
            case
              when cur_cells.MERGEACROSS = 0 then ''
              else ' ss:MergeAcross="' || cur_cells.MERGEACROSS ||'"'
            end ||
            case
              when cur_cells.MERGEDOWN = 0 then ''
              else ' ss:MergeDown="' || cur_cells.MERGEDOWN ||'"'
            end ||
            case
              when upper(cur_cells.CELLTYPE) = 'EMPTY' then '/>'
              when upper(cur_cells.CELLTYPE) = 'FORMULA' then ' ss:Formula="' || SP_CHAR_REPL(cur_cells.CELLDATA) || '"/>'
                -- Для пустых числел не надо Data формировать, иначе печатется 0
              when upper(cur_cells.CELLTYPE) = 'NUMBER' and cur_cells.CELLDATA is null then '/>'
              else '><' ||
                case when cur_cells.FORMATCELL = 1 then 'ss:Data xmlns="http://www.w3.org/TR/REC-html40" ' else 'Data ' end ||
                'ss:Type="' || cur_cells.CELLTYPE || '">' ||
                case cur_cells.FORMATCELL
                  when 0 then SP_CHAR_REPL( cur_cells.CELLDATA )
                  else cur_cells.CELLDATA
                end ||
                '</Data></Cell>'
            end;

          nCELLINDEX := nCELLINDEX + nvl( cur_cells.MERGEACROSS, 0 );

          PUT_LINE( sCELL );
        end loop;
        nINDENT := nINDENT-1;
        PUT_LINE( '</Row>' );
      end loop;

    -- XLSX
    elsif nREPORTTYPE = 1 then
      -- добавление пустых ячеек в область объединения снизу
      for cur_merge in
      (
        select c.*
          from A_XLSROWS r
          join A_XLSCELLS c on c.PRN = r.RN
         where r.SKIP = 0
           and c.SKIP = 0
           and c.MERGEDOWN > 0
         order by r.RN, c.RN
      )
      loop
        for i in 1 .. cur_merge.MERGEDOWN loop
          -- *** проверка дыры внизу (отсутствие строк)
          if nROWCOUNT < cur_merge.PRN + i then--if EXISTS_ROW( cur_merge.PRN + i ) = 0 then
            ADD_ROW_BASE( );
          end if;

          -- *** проверка дыры слева: закрываем добавлением пустых ячеек по кол-ву дыр
          ADD_CELL_EMPTY
          (
            nCOUNT      => cur_merge.COLNUMB - GET_COLNUMBER_LAST( cur_merge.PRN + i ) - 1,
            nROWNUM     => cur_merge.PRN + i,
            sCELLTYPE   => cur_merge.CELLTYPE,
            nSKIP       => cur_merge.SKIP,
            sTAG        => cur_merge.TAG,
            nWITHFORMAT => cur_merge.FORMATCELL,
            sCONDFORMAT => cur_merge.CONDFORMAT
          );

          if EXISTS_CELL( cur_merge.PRN + i, cur_merge.COLNUMB ) = 0 then
            nCURCELL_RN := nCURCELL_RN + 1;

            ADD_CELL_BASE
            (
              sCELLDATA    => '',
              sCELLTYPE    => cur_merge.CELLTYPE,
              nROWNUMBER   => cur_merge.PRN + i,
              sSTYLE       => cur_merge.STYLE,
              nMERGEACROSS => cur_merge.MERGEACROSS,
              nMERGEDOWN   => 0,
              nSKIP        => cur_merge.SKIP,
              sTAG         => cur_merge.TAG,
              nWITHFORMAT  => cur_merge.FORMATCELL,
              nSKIPINDEX   => 0,
              sCONDFORMAT  => cur_merge.CONDFORMAT,
              nAUTO_EMPTY  => 1
            );
          else
            UPD_CELL_BASE
            (
              nROWNUM      => cur_merge.PRN + i,
              nCOLNUM      => cur_merge.COLNUMB,
              sSTYLE       => cur_merge.STYLE
            );
        end if;
        end loop;

        lMERGEDOWN := true;*/
        null;
      end loop;

      -- повторно перезаполняем из коллекции
      if lOPTIMIZE_INSERT and lMERGEDOWN then
        delete from A_XLSCELLS;
        delete from A_XLSROWS;

        forall i in 1..vXLSROWS.count
         insert into A_XLSROWS values vXLSROWS(i);

        forall i in 1..vXLSCELLS.count
         insert into A_XLSCELLS values vXLSCELLS(i);
      end if;

      dbms_lob.createtemporary( cMERGE, true );
      dbms_lob.createtemporary( cPAGEBREAK, true );
      DBMS_LOB.createtemporary( cCLOBXLS, true );

      if lCOLSOPEN then
        PUT_LINEXLSX( '</cols>' );
        lCOLSOPEN := false;
      end if;
      PUT_LINEXLSX( '<sheetData>' );

      nBREAK_CNT := 0;

      for cur_rows in
      (
        select r.RN, r.HEIGHT, r.AUTOFIT, r.PAGEBREAK
          from A_XLSROWS r
         where r.SKIP=0
         order by r.RN
      )
      loop
        PUT_LINEXLSX( '<row r="' || cur_rows.RN || '" '
                  || case when cur_rows.HEIGHT is not null then ' ht="' || cur_rows.HEIGHT || '" customHeight="1"' end || '>' );

        iCOLNUMBER := 0;

        for cur_cells in
        (
          select c.STYLE,
                 c.CELLDATA,
                 c.CELLTYPE,
                 c.MERGEACROSS,
                 c.MERGEDOWN,
                 c.FORMATCELL,
                 c.AUTO_EMPTY
          from A_XLSCELLS c
          where c.PRN = cur_rows.RN
            and c.SKIP = 0
          order by c.COLNUMB
        )
        loop
          iCOLNUMBER := iCOLNUMBER + 1;

          sCELL := '<c ' || 'r="' ||  GET_COL_NAME( iCOLNUMBER ) || to_char( cur_rows.rn ) || '" s="' || rSTYLEIDS( cur_cells.STYLE ) || '" ';
          if cur_cells.celldata is not null then
            sCELL := sCELL || case cur_cells.celltype when 'String' then 't="s"' end || '>';
            if cur_cells.celltype = 'Number' then
              cur_cells.CELLDATA := replace(cur_cells.celldata, sDecimal, '.');
              sCELL := sCELL || '<v>' || cur_cells.celldata || '</v>';
            elsif cur_cells.celltype = 'String' then
              if rSHAREDSTRINGS.exists( cur_cells.celldata ) then
                sCELL := sCELL || '<v>' || rSHAREDSTRINGS( cur_cells.celldata ) || '</v>';
              else
                rSHAREDSTRINGS( cur_cells.celldata ) := iSTRINGID;
                PUT_LINE( 'xl/sharedStrings.xml', '<si><t>'
                          || case cur_cells.formatcell when 0 then SP_CHAR_REPL( cur_cells.celldata ) else cur_cells.celldata end || '</t></si>' );
                sCELL := sCELL || '<v>' || iSTRINGID || '</v>';
                iSTRINGID := iSTRINGID + 1;
              end if;
            elsif cur_cells.celltype = 'Formula' then
              sCELL := sCELL ||'<f>'|| VALIDATE_FORMULA( cur_cells.celldata, cur_rows.rn, iCOLNUMBER ) ||'</f>';
            end if;
            sCELL := sCELL || '</c>';
          else
            sCELL := sCELL || '/>';
          end if;

        if cur_cells.AUTO_EMPTY = 0 then
          -- объединение вправо
          if cur_cells.mergeacross > 0 and cur_cells.mergedown = 0 then
            sMERGE := '<mergeCell ref="' || GET_COL_NAME( iCOLNUMBER ) || cur_rows.rn || ':'
                                         || GET_COL_NAME( iCOLNUMBER + cur_cells.mergeacross ) || cur_rows.rn || '"/>';

            DBMS_LOB.WRITEAPPEND( cMERGE, length( sMERGE ), sMERGE );

            for i in 1..cur_cells.mergeacross
            loop
              sCELL := sCELL || '<c ' || 'r="' ||  GET_COL_NAME( iCOLNUMBER + i ) || to_char( cur_rows.rn ) || '" ' || 's="' || rSTYLEIDS( cur_cells.STYLE ) || '" />';
            end loop;

            iCOLNUMBER := iCOLNUMBER + cur_cells.mergeacross;
          end if;

          -- объединение вниз
          if cur_cells.mergedown > 0 and cur_cells.mergeacross = 0 then
            sMERGE := '<mergeCell ref="' || GET_COL_NAME( iCOLNUMBER ) || cur_rows.rn || ':'
                                         || GET_COL_NAME( iCOLNUMBER ) || to_char(cur_rows.rn + cur_cells.mergedown) || '"/>';

            DBMS_LOB.WRITEAPPEND( cMERGE, length( sMERGE ), sMERGE );
          end if;

          -- объединение вправо и вниз

              if cur_cells.mergeacross > 0 and cur_cells.mergedown > 0 then
                sMERGE := '<mergeCell ref="' || GET_COL_NAME( iCOLNUMBER ) || cur_rows.rn || ':'
                                             || GET_COL_NAME( iCOLNUMBER + cur_cells.mergeacross ) || to_char(cur_rows.rn + cur_cells.mergedown) || '"/>';

                DBMS_LOB.WRITEAPPEND( cMERGE, length( sMERGE ), sMERGE );

                for i in 1..cur_cells.mergeacross
                loop
                  sCELL := sCELL || '<c ' || 'r="' ||  GET_COL_NAME( iCOLNUMBER + i ) || to_char( cur_rows.rn ) || '" ' || 's="' || rSTYLEIDS( cur_cells.STYLE ) || '" />';
                end loop;

                iCOLNUMBER := iCOLNUMBER + cur_cells.mergeacross;
              end if;
          end if;


          PUT_LINEXLSX( sCELL );
        end loop;
        PUT_LINEXLSX( '</row>' );

        if cur_rows.pagebreak > 0 then
          cPAGEBREAK := cPAGEBREAK || '<brk id="'||cur_rows.rn||'" max="16383" man="1"/>';
          nBREAK_CNT := nBREAK_CNT + 1;
        end if;
      end loop;

      -- !!! По-хорошему, надо перенести в CLOSE_SHEET
      -- проблемы из-за cPAGEBREAK и cMERGE
      PUT_LINEXLSX( '</sheetData>' );

      if nPROTECTED=1 then
        --PUT_LINE( sCURRENTSHEET, '<sheetProtection algorithmName="MD5" hashValue="'||SYS.DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW (sPASSWORD, 'AL32UTF8'), sys.dbms_crypto.HASH_MD5)||'" sheet="1" objects="1" scenarios="1"/>' );
        --p_exception(0, lower(to_char(rawtohex(SYS.DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW (sPASSWORD, 'AL32UTF8'), sys.dbms_crypto.hash_sh1)))));
        PUT_LINEXLSX( '<sheetProtection password="'||GET_HASH(sPASSWORD)||'" sheet="1" objects="1" scenarios="1"/>' );
      end if;

      if nAUTOFILTERX = 1 then
        PUT_LINEXLSX( '<autoFilter ref="' || GET_COL_NAME( nAUTOFILTERX_C1 ) || to_char( nAUTOFILTERX_R1 ) || ':'
                                                     || GET_COL_NAME( nAUTOFILTERX_C2 ) || to_char( nAUTOFILTERX_R2 ) || '"/>' );
      end if;

      if cMERGE is not null and length( cMERGE ) > 0 then
        PUT_LINEXLSX( '<mergeCells>' );
        --rFILES( sCURRENTSHEET ) := rFILES( sCURRENTSHEET ) || cMERGE;
        cCLOBXLS := cCLOBXLS||cMERGE;
        PUT_LINEXLSX( '</mergeCells>' );
        dbms_lob.freetemporary( cMERGE );
      end if;

      PUT_LINEXLSX( '<phoneticPr fontId="0" type="noConversion"/>' );

      -- условное форматирование
      for condf in
      (
        select distinct c.CONDFORMAT
          from A_XLSCELLS c
         where c.CONDFORMAT is not null
           and c.SKIP = 0
      )
      loop
        sCELL_CONDFORMAT := null;

        -- ячейки
        for cur_rows in
        (
          select r.RN
            from A_XLSROWS r
           where r.SKIP=0
           order by r.RN
        )
        loop
          iCOLNUMBER := 0;

          for cur_cells in
          (
            select c.CONDFORMAT,
                   c.MERGEACROSS
              from A_XLSCELLS c
             where c.PRN = cur_rows.RN
               and c.SKIP = 0
             order by c.COLNUMB
          )
          loop
            iCOLNUMBER := iCOLNUMBER + 1;

            -- объединение вправо
            if cur_cells.mergeacross > 0 then
              iCOLNUMBER := iCOLNUMBER + cur_cells.mergeacross;
            end if;

            if cur_cells.CONDFORMAT = condf.CONDFORMAT then
              -- !!! по-хорошему, нужно делать через интервалы
              if sCELL_CONDFORMAT is null then
                sCELL_CONDFORMAT := sCELL_CONDFORMAT||GET_COL_NAME( iCOLNUMBER ) || cur_rows.rn;
              else
                sCELL_CONDFORMAT := sCELL_CONDFORMAT||' '||GET_COL_NAME( iCOLNUMBER ) || cur_rows.rn;
              end if;
            end if;
          end loop;
        end loop;

        -- !!!
        begin
          PUT_LINEXLSX( replace( rCONDFORMAT( condf.CONDFORMAT ), '##RANGE##', sCELL_CONDFORMAT ));
        exception
          when no_data_found then
            ap_exception( 0, 'К ячейке применяется условное форматирование "%s", которое не описано!', condf.CONDFORMAT );
        end;
      end loop;

      PUT_LINEXLSX( '<pageMargins left="'||bMARGINBOTTOM||'" right="'||bMARGINLEFT||'" top="'||bMARGINRIGHT||'" bottom="'||bMARGINTOP||'" header="0.1" footer="0.1"/>' );

      if sORIENTATION is not null then
        PUT_LINEXLSX( '<pageSetup paperSize="9" fitToHeight="0"' ||
                                           ' orientation="' || lower( sORIENTATION ) || '"' ||
                                           ' verticalDpi="0" r:id="rId' || to_char( iSHEETID ) ||'"/>' );
      end if;

      -- колонтитулы
      if сST_RUNTITLE is not null then
        PUT_LINEXLSX( сST_RUNTITLE );
      end if;

      if cPAGEBREAK is not null and length( cPAGEBREAK ) > 0 then
        PUT_LINEXLSX( '<rowBreaks count="'||nBREAK_CNT||'" manualBreakCount="'||nBREAK_CNT||'">' );
        --rFILES( sCURRENTSHEET ) := rFILES( sCURRENTSHEET ) || cPAGEBREAK;
        cCLOBXLS := cCLOBXLS||cPAGEBREAK;
        PUT_LINEXLSX( '</rowBreaks>' );
        dbms_lob.freetemporary( cPAGEBREAK );
      end if;

      rFILES( sCURRENTSHEET ) := rFILES( sCURRENTSHEET )||cCLOBXLS;
      dbms_lob.freetemporary( cCLOBXLS );
    end if;
  end;

  -- демо отчет для иллюстрации возможностей технологии (c колонтитулом)
  procedure DEMO_REP
  (
    oBLOB           out blob
  )
  is
  begin
    -- открываем отчет
    OPEN_REPORT
    (
      nTYPE           => 1,               -- Тип отчета ( 0 - XLSXML, 1 - XLSX )
      sAUTHOR         => 'Новая Система', -- Автор
      sLASTAUTHOR     => 'Не указан',     -- Последний редактировавший
      sCOMPANY        => 'Новая Система', -- Организация
      sAPP            => 'Demo',          -- Приложение
      sENCODING       => 'Windows-1251',  -- Кодировка
      nSTARTINDENT    => 0,               -- Начальный отступ
      nADDDEFSTYLE    => 1                -- Добавить стиль по умолчанию (Arial Cyr, 10)
    );

    -- ***********************************************************************************
    -- СТИЛИ
    -- ***********************************************************************************
    ADD_STYLE
    (
      sSTYLE              => 'Default',   -- ID стиля
      sNAME               => null,        -- Наименование стиля
      sHALIGNMENT         => 'Left',      -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
      sVALIGNMENT         => 'Center',    -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      sINDENT             => '0',         -- Отступ
      nWRAPTEXT           => 0,           -- Перенос текста (0, 1)
      sBORDERTOPSTYLE     => 'Continuous',-- Верхняя граница ячейки (Continuous, Dot)
      sBORDERBOTTOMSTYLE  => 'Continuous',-- Нижняя граница ячейки (Continuous, Dot)
      sBORDERLEFTSTYLE    => 'Continuous',-- Левая граница ячейки (Continuous, Dot)
      sBORDERRIGHTSTYLE   => 'Continuous',-- Правая граница ячейки (Continuous, Dot)
      nBORDERTOPWEIGHT    => 0,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 0,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 0,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 0,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      sFONTNAME           => 'Verdana',   -- Название шрифта
      sCHARSET            => '204',       -- Код набора символов
      nFONTSIZE           => 10,          -- Размер шрифта
      nFONTBOLD           => 0,           -- Болд (0, 1)
      nFONTITALIC         => 0,           -- Курсив
      sFONTCOLOR          => '#000000',   -- Цвет шрифта
      sBACKCOLOR          => null,        -- Цвет фона '#FFFFFF'
      sPATTERN            => null,        -- Кисть фона 'Solid'
      sNUMBERFORMAT       => null         -- Формат числа
    );
    -- заголовок
    ADD_STYLE
    (
      sSTYLE              => 'title_rep', -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      nFONTSIZE           => 14,          -- Размер шрифта
      nFONTBOLD           => 1,           -- Болд (0, 1)
      nFONTITALIC         => 1,           -- Курсив
      sFONTCOLOR          => '38'         -- Цвет шрифта
    );

    -- шапка таблицы
    ADD_STYLE
    (
      sSTYLE              => 'title_tab', -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      nFONTSIZE           => 14,          -- Размер шрифта
      nFONTBOLD           => 1,           -- Болд (0, 1)
      sBACKCOLOR          => '#99CCFF',   -- Цвет фона '#FFFFFF'
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      sHALIGNMENT         => 'Center'     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
    );

    -- строка группировки
    ADD_STYLE
    (
      sSTYLE              => 'grp_type',  -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      nFONTSIZE           => 12,          -- Размер шрифта
      nFONTBOLD           => 1,           -- Болд (0, 1)
      nFONTITALIC         => 1,           -- Курсив
      sBACKCOLOR          => '#CCFFFF',   -- Цвет фона '#FFFFFF'
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      sHALIGNMENT         => 'Center'     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
    );

    -- столбец 1
    ADD_STYLE
    (
      sSTYLE              => 'col_1',     -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      sINDENT             => '1',         -- Отступ
      nFONTBOLD           => 1,           -- Болд (0, 1)
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1            -- Правая граница ячейки, толщина (если 0, то не формируется)
    );

    -- столбцы 2,3 бкз защиты
    ADD_STYLE
    (
      sSTYLE              => 'col_23',    -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1            -- Правая граница ячейки, толщина (если 0, то не формируется)
    );

    -- столбцы 2,3 с защитой
    ADD_STYLE
    (
      sSTYLE              => 'col_23prot',    -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      nPROTECTION         => 0,
      sFONTCOLOR          => '2'          -- Цвет шрифта
    );

    -- столбцы 4,5
    ADD_STYLE
    (
      sSTYLE              => 'col_45',    -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1            -- Правая граница ячейки, толщина (если 0, то не формируется)
    );

    -- столбцы 6
    ADD_STYLE
    (
      sSTYLE              => 'col_6',     -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      sHALIGNMENT         => 'Right',     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
      nFONTBOLD           => 1,           -- Болд (0, 1)
      sFONTCOLOR          => '4',         -- Цвет шрифта
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1            -- Правая граница ячейки, толщина (если 0, то не формируется)
    );
    -- ***********************************************************************************

    -----------------------------------------------------------
    -- лист1 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Книги',     -- Название листа.
      nPROTECTED        => 1,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 4,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 2,
      nOPTIMIZE_INSERT  => 0,           -- Оптимизация добавления ячеек
      sPASSWORD         => 'abcdefghij' -- Пароль для отключения защиты листа
    );

    -- колонтитул
    ADD_RUNTITLE( sHEADERLEFT => '&amp;"Vani,обычный"&amp;10&amp;K995555Колонтитул листа &amp;A',
                  sFOOTERCENTER => '&amp;P из &amp;N' );

    -- открываем табличную область
    OPEN_TABLE();

    ADD_COLUMN( nWIDTH => 59 );
    ADD_COLUMN( nWIDTH => 89 );
    ADD_COLUMN( nWIDTH => 204 );
    ADD_COLUMN( nWIDTH => 38 );
    ADD_COLUMN( nWIDTH => 124 );
    ADD_COLUMN( nWIDTH => 106 );

    ADD_ROW( nHEIGHT => 17 );

    ADD_ROW( nHEIGHT => 25 );

    ADD_CELL( sSTYLE => 'Default', sCELLDATA => '', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'title_rep', sCELLDATA => 'Список книг по программированию', sCELLTYPE => 'String', nMERGEACROSS => 4 );

    ADD_ROW( nHEIGHT => 17 );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => '№ п.п.', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Автор', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Название', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Год', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Издательство', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Цена в магазине Озон', sCELLTYPE => 'String' );

    ADD_ROW( nHEIGHT => 20 );
    ADD_CELL( sSTYLE => 'grp_type', sCELLDATA => 'Python', sCELLTYPE => 'String', nMERGEACROSS => 5 );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '1', sCELLTYPE => 'Number', nMERGEDOWN => 1 );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'Марк Лутц', sCELLTYPE => 'String', nMERGEDOWN => 1 );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'Изучаем Python', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2011', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Символ-Плюс', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '100', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '1', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Марк Лутц', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Python. Карманный справочник', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Вильямс', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '150', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '2', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'А. Головатый, Дж. Каплан-Мосс', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'Django. Подробное руководство', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2010', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Символ-Плюс', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '255', sCELLTYPE => 'Number' );

    for i in 1..25
    loop
      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '3', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Дэвид Бизли', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Python. Подробное руководство', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2010', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Символ-Плюс', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '99', sCELLTYPE => 'Number' );
    end loop;

    ADD_ROW( nHEIGHT => 20 );
    ADD_CELL( sSTYLE => 'grp_type', sCELLDATA => 'Java', sCELLTYPE => 'String', nMERGEACROSS => 5 );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '5', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'Герберт Шилдт', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'Java. Полное руководство', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2012', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Вильямс', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '350', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '6', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Брюс Эккель', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Философия Java', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Питер', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '145', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '7', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'Роберт Лафоре', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_23prot', sCELLDATA => 'Структуры данных и алгоритмы в Java', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Питер', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '560', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '8', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Патрик Нимейер, Даниэл Леук', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Программирование на Java', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Эксмо', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '330', sCELLTYPE => 'Number' );

    ADD_ROW( nHEIGHT => 17, nPAGEBREAK => 1 );

    ADD_ROW( nHEIGHT => 17 );
    ADD_CELL( sSTYLE => 'Default', sCELLDATA => 'Телепрограмма', sCELLTYPE => 'String' );

    ADD_ROW( nHEIGHT => 17 );
    ADD_CELL( sSTYLE => 'Default', sCELLDATA => '9-00', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'Default', sCELLDATA => 'Вести', sCELLTYPE => 'String' );

    ADD_ROW( nHEIGHT => 17 );
    ADD_CELL( sSTYLE => 'Default', sCELLDATA => '9-35', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'Default', sCELLDATA => 'Новости', sCELLTYPE => 'String' );

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();

    -----------------------------------------------------------
    -- лист2 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Итоги',     -- Название листа.
      nPROTECTED        => 1,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 0,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 0,
      nOPTIMIZE_INSERT  => 0            -- Оптимизация добавления ячеек
    );

    -- открываем табличную область
    OPEN_TABLE();

    ADD_COLUMN( nWIDTH => 50 );
    ADD_COLUMN( nWIDTH => 100 );
    ADD_COLUMN( nWIDTH => 50 );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '1', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Марк Лутц', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '100', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '2', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Евгений Карев', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '200', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '3', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Андрей Кольчугин', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '300', sCELLTYPE => 'Number' );

    ADD_ROW( nAUTOFIT => 0 );
    ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '', sCELLTYPE => 'Number' );
    ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Итого', sCELLTYPE => 'String' );
    ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '=SUM(C1:C3)', sCELLTYPE => 'Formula' );

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();

    -- закрываем отчет
    CLOSE_REPORT();

    oBLOB := GET_BLOB;
  exception
    when others then
      FREE_BLOB();
      raise;
  end;

  -- Максимально простой отчет для вывода одной ячейки
  procedure DEMO_REP_1CELL
  (
    oBLOB           out blob
  )
  is
  begin
    -- открываем отчет
    OPEN_REPORT
    (
      nTYPE           => 1,               -- Тип отчета ( 0 - XLSXML, 1 - XLSX )
      sAUTHOR         => 'Новая Система', -- Автор
      sLASTAUTHOR     => 'Не указан',     -- Последний редактировавший
      sCOMPANY        => 'Новая Система', -- Организация
      sAPP            => 'Demo',          -- Приложение
      sENCODING       => 'UTF-8',         -- Кодировка
      nSTARTINDENT    => 0,               -- Начальный отступ
      nADDDEFSTYLE    => 1                -- Добавить стиль по умолчанию (Arial Cyr, 10)
    );

    -----------------------------------------------------------
    -- лист1 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Book',      -- Название листа.
      nPROTECTED        => 0,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 0,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 0,
      nOPTIMIZE_INSERT  => 0            -- Оптимизация добавления ячеек
    );

    -- открываем табличную область
    OPEN_TABLE();

    ADD_COLUMN( nWIDTH => 59 );

    ADD_ROW( nHEIGHT => 25 );

    ADD_CELL( sSTYLE => 'Default', sCELLDATA => '1', sCELLTYPE => 'String' );

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();

    -----------------------------------------------------------
    -- лист2 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Книга 2',      -- Название листа.
      nPROTECTED        => 0,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 0,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 0,
      nOPTIMIZE_INSERT  => 0            -- Оптимизация добавления ячеек
    );

    -- открываем табличную область
    OPEN_TABLE();

    ADD_COLUMN( nWIDTH => 59 );

    ADD_ROW( nHEIGHT => 25 );

    ADD_CELL( sSTYLE => 'Default', sCELLDATA => '2', sCELLTYPE => 'String' );

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();

    -- закрываем отчет
    CLOSE_REPORT();

    oBLOB := GET_BLOB;
  exception
    when others then
      FREE_BLOB();
      raise;
  end;

  -- Максимально простой отчет для вывода таблицы для последующей загрузки
  procedure DEMO_REP_TABLE
  (
    oBLOB           out blob
  )
  is
  begin
    -- открываем отчет
    OPEN_REPORT
    (
      nTYPE           => 1,               -- Тип отчета ( 0 - XLSXML, 1 - XLSX )
      sAUTHOR         => 'Новая Система', -- Автор
      sLASTAUTHOR     => 'Не указан',     -- Последний редактировавший
      sCOMPANY        => 'Новая Система', -- Организация
      sAPP            => 'DemoTable',     -- Приложение
      sENCODING       => 'UTF-8',         -- Кодировка
      nSTARTINDENT    => 0,               -- Начальный отступ
      nADDDEFSTYLE    => 1                -- Добавить стиль по умолчанию (Arial Cyr, 10)
    );

    -----------------------------------------------------------
    -- лист1 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Book',      -- Название листа.
      nPROTECTED        => 0,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 0,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 0,
      nOPTIMIZE_INSERT  => 0            -- Оптимизация добавления ячеек
    );

    -- открываем табличную область
    OPEN_TABLE();

    ADD_COLUMN( nWIDTH => 0 );
    ADD_COLUMN( nWIDTH => 59 );
    ADD_COLUMN( nWIDTH => 59 );

    for i in 1..50
    loop
      if i = 1 then
        ADD_ROW( nHEIGHT => 0 );
      else
        ADD_ROW( nHEIGHT => 25 );
      end if;

      ADD_CELL( sSTYLE => 'Default', sCELLDATA => i + i/3, sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'Default', sCELLDATA => to_char(i), sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'Default', sCELLDATA => to_char( sysdate + i, 'dd.mm.yyyy' ), sCELLTYPE => 'String' );
    end loop;

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();

    -- закрываем отчет
    CLOSE_REPORT();

    oBLOB := GET_BLOB;
  exception
    when others then
      FREE_BLOB();
      raise;
  end;

  -- процедура построения отчета с большим количеством строк
  procedure DEMO_BIG_REP
  (
    oBLOB           out blob
  )
  is
    procedure PRINT_DET
    is
    begin
      ADD_ROW( nHEIGHT => 20 );
      ADD_CELL( sSTYLE => 'grp_type', sCELLDATA => 'Python', sCELLTYPE => 'String', nMERGEACROSS => 5 );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '1', sCELLTYPE => 'Number', nMERGEDOWN => 1 );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Марк Лутц', sCELLTYPE => 'String', nMERGEDOWN => 1 );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Изучаем Python', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2011', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Символ-Плюс', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '100', sCELLTYPE => 'Number' );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '1', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Марк Лутц', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Python. Карманный справочник', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Вильямс', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '150', sCELLTYPE => 'Number' );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '2', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'А. Головатый, Дж. Каплан-Мосс', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Django. Подробное руководство', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2010', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Символ-Плюс', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '255', sCELLTYPE => 'Number' );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '3', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Дэвид Бизли', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Python. Подробное руководство', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2010', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Символ-Плюс', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '99', sCELLTYPE => 'Number' );

      ADD_ROW( nHEIGHT => 20 );
      ADD_CELL( sSTYLE => 'grp_type', sCELLDATA => 'Java', sCELLTYPE => 'String', nMERGEACROSS => 5 );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '5', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Герберт Шилдт', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Java. Полное руководство', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2012', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Вильямс', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '350', sCELLTYPE => 'Number' );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '6', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Брюс Эккель', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Философия Java', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Питер', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '145', sCELLTYPE => 'Number' );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '7', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Роберт Лафоре', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Структуры данных и алгоритмы в Java', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Питер', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '560', sCELLTYPE => 'Number' );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'col_1', sCELLDATA => '8', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Патрик Нимейер, Даниэл Леук', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_23', sCELLDATA => 'Программирование на Java', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => '2014', sCELLTYPE => 'Number' );
      ADD_CELL( sSTYLE => 'col_45', sCELLDATA => 'Эксмо', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'col_6', sCELLDATA => '330', sCELLTYPE => 'Number' );
    end;

    procedure PRINT_SHEET
    (
      nNUM          in number
    )
    is
    begin
      ADD_COLUMN( nWIDTH => 59 );
      ADD_COLUMN( nWIDTH => 89 );
      ADD_COLUMN( nWIDTH => 204 );
      ADD_COLUMN( nWIDTH => 38 );
      ADD_COLUMN( nWIDTH => 124 );
      ADD_COLUMN( nWIDTH => 106 );

      ADD_ROW( nHEIGHT => 17 );

      ADD_ROW( nHEIGHT => 25 );

      ADD_CELL( sSTYLE => 'title_rep', sCELLDATA => '', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'title_rep', sCELLDATA => 'Список книг по программированию', sCELLTYPE => 'String', nMERGEACROSS => 4 );

      ADD_ROW( nHEIGHT => 17 );

      ADD_ROW( nAUTOFIT => 0 );
      ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => '№ п.п.', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Автор', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Название', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Год', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Издательство', sCELLTYPE => 'String' );
      ADD_CELL( sSTYLE => 'title_tab', sCELLDATA => 'Цена в магазине Озон', sCELLTYPE => 'String' );

      for i in 1..nNUM
      loop
        PRINT_DET;
      end loop;
    end;

  begin
    -- открываем отчет
    OPEN_REPORT
    (
      nTYPE           => 1,               -- Тип отчета ( 0 - XLSXML, 1 - XLSX )
      sAUTHOR         => 'Новая Система', -- Автор
      sLASTAUTHOR     => 'Не указан',     -- Последний редактировавший
      sCOMPANY        => 'Новая Система', -- Организация
      sAPP            => 'Demo',          -- Приложение
      sENCODING       => 'Windows-1251',  -- Кодировка
      nSTARTINDENT    => 0,               -- Начальный отступ
      nADDDEFSTYLE    => 1                -- Добавить стиль по умолчанию (Arial Cyr, 10)
    );

    -- ***********************************************************************************
    -- СТИЛИ
    -- ***********************************************************************************
    -- заголовок
    ADD_STYLE
    (
      sSTYLE              => 'title_rep', -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      nFONTSIZE           => 14,          -- Размер шрифта
      nFONTBOLD           => 1,           -- Болд (0, 1)
      nFONTITALIC         => 1,           -- Курсив
      sFONTCOLOR          => '38'         -- Цвет шрифта
    );

    -- шапка таблицы
    ADD_STYLE
    (
      sSTYLE              => 'title_tab', -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      nFONTSIZE           => 14,          -- Размер шрифта
      nFONTBOLD           => 1,           -- Болд (0, 1)
      sBACKCOLOR          => '#99CCFF',   -- Цвет фона '#FFFFFF'
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      sHALIGNMENT         => 'Center'     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
    );

    -- строка группировки
    ADD_STYLE
    (
      sSTYLE              => 'grp_type',  -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      nFONTSIZE           => 12,          -- Размер шрифта
      nFONTBOLD           => 1,           -- Болд (0, 1)
      nFONTITALIC         => 1,           -- Курсив
      sBACKCOLOR          => '#CCFFFF',   -- Цвет фона '#FFFFFF'
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      sHALIGNMENT         => 'Center'     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
    );

    -- столбец 1
    ADD_STYLE
    (
      sSTYLE              => 'col_1',     -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      sINDENT             => '1',         -- Отступ
      nFONTBOLD           => 1,           -- Болд (0, 1)
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1            -- Правая граница ячейки, толщина (если 0, то не формируется)
    );

    -- столбцы 2,3
    ADD_STYLE
    (
      sSTYLE              => 'col_23',    -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      nPROTECTION         => 0
    );

    -- столбцы 4,5
    ADD_STYLE
    (
      sSTYLE              => 'col_45',    -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1            -- Правая граница ячейки, толщина (если 0, то не формируется)
    );

    -- столбцы 6
    ADD_STYLE
    (
      sSTYLE              => 'col_6',     -- ID стиля
      sFONTNAME           => 'Arial Cyr', -- Название шрифта
      sVALIGNMENT         => 'Top',       -- Вертикальное выравнивание (Top, Bottom, Center, Justify, Distributed, JustifyDistributed)
      sHALIGNMENT         => 'Right',     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
      nFONTBOLD           => 1,           -- Болд (0, 1)
      sFONTCOLOR          => '4',         -- Цвет шрифта
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1            -- Правая граница ячейки, толщина (если 0, то не формируется)
    );
    -- ***********************************************************************************

    -----------------------------------------------------------
    -- лист1 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Книги',     -- Название листа.
      nPROTECTED        => 1,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 0,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 0,
      nOPTIMIZE_INSERT  => 1,           -- Оптимизация добавления ячеек
      sPASSWORD         => 'abcdefghij' -- Пароль для отключения защиты листа
    );

    -- открываем табличную область
    OPEN_TABLE();

    PRINT_SHEET(1000);

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();

    -----------------------------------------------------------
    -- лист2 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Лист2',     -- Название листа.
      nPROTECTED        => 1,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 0,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 0,
      nOPTIMIZE_INSERT  => 1            -- Оптимизация добавления ячеек
    );

    -- открываем табличную область
    OPEN_TABLE();

    PRINT_SHEET(1000);

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();


    -----------------------------------------------------------
    -- лист3 --------------------------------------------------
    -- открываем лист
    OPEN_SHEET
    (
      sSHEETNAME        => 'Лист3',     -- Название листа.
      nPROTECTED        => 1,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 0,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 0,
      nOPTIMIZE_INSERT  => 1            -- Оптимизация добавления ячеек
    );

    -- открываем табличную область
    OPEN_TABLE();

    PRINT_SHEET(1000);

    -- выгружаем сформированные строки и столбцы
    FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    CLOSE_TABLE_AND_SHEET();

    -- закрываем отчет
    CLOSE_REPORT();

    oBLOB := GET_BLOB;
  end;

  -- пример отчета с объединением ячеек и условным форматированием
  procedure DEMO_REP_MERGE
  (
    oBLOB           out blob
  )
  is
    nROWHEAD1                 integer;
    nROWHEAD2                 integer;
    nROWHEAD3                 integer;

  begin
    -- открываем отчет
    OPEN_REPORT
    (
      nTYPE           => 1,               -- Тип отчета ( 0 - XLSXML, 1 - XLSX )
      sAUTHOR         => 'Новая Система', -- Автор
      sLASTAUTHOR     => 'Не указан',     -- Последний редактировавший
      sCOMPANY        => 'Новая Система', -- Организация
      sAPP            => 'Demo',          -- Приложение
      sENCODING       => 'Windows-1251',  -- Кодировка
      nSTARTINDENT    => 0,               -- Начальный отступ
      nADDDEFSTYLE    => 1                -- Добавить стиль по умолчанию (Arial Cyr, 10)
    );

    -- ***********************************************************************************
    -- СТИЛИ
    -- ***********************************************************************************
    -- шапка таблицы
    APKG_XLSREP.ADD_STYLE
    (
      sSTYLE              => 'head_tab',  -- ID стиля
      nFONTBOLD           => 1,           -- Болд (0, 1)
      sBACKCOLOR          => '#99CCFF',   -- Цвет фона '#FFFFFF'
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      sHALIGNMENT         => 'Center'     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
    );

    -- ячейки
    APKG_XLSREP.ADD_STYLE
    (
      sSTYLE              => 'cell',      -- ID стиля
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      sHALIGNMENT         => 'Left'       -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
    );

    -- ячейки с числами
    APKG_XLSREP.ADD_STYLE
    (
      sSTYLE              => 'cell_num',  -- ID стиля
      nBORDERTOPWEIGHT    => 1,           -- Верхняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERBOTTOMWEIGHT => 1,           -- Нижняя граница ячейки, толщина (если 0, то не формируется)
      nBORDERLEFTWEIGHT   => 1,           -- Левая граница ячейки, толщина (если 0, то не формируется)
      nBORDERRIGHTWEIGHT  => 1,           -- Правая граница ячейки, толщина (если 0, то не формируется)
      nWRAPTEXT           => 1,           -- Перенос текста (0, 1)
      sHALIGNMENT         => 'Right',     -- Горизонтальное выравнивание (Left, Right, Center, CenterAcrossSelection, Distributed, JustifyDistributed)
      sNUMBERFORMAT       => '#,##0.000;-#,##0.000' -- Формат числа
    );

    -- условное форматирование
    -- трехцветная шкала
    ADD_CONDFORMAT_XLSX( sCONDFORMAT         => 'cscale3',
                         sCONDTYPE           => 'colorScale',
                         -- цветовая шкала - минимальное значение
                         sCSCALE_MINTYPE     => 'percentile',
                         sCSCALE_MINVALUE    => '10',
                         sCSCALE_MINCOLOR    => '#FF7128',
                         -- цветовая шкала - среднее значение (для трехцветной шкалы)
                         sCSCALE_AVGTYPE     => 'percentile',
                         sCSCALE_AVGVALUE    => '50',
                         sCSCALE_AVGCOLOR    => '#FFEB84',
                         -- цветовая шкала - максимальное значение
                         sCSCALE_MAXTYPE    => 'max',
                         sCSCALE_MAXVALUE   => '',
                         sCSCALE_MAXCOLOR   => 'FFFFEF9C'
                       );

    -- значение ячейки между
    ADD_CONDFORMAT_XLSX( sCONDFORMAT         => 'cellIs1',
                         sCONDTYPE           => 'cellIs',
                         sOPERATOR           => 'between',
                         sVALUE1             => '1',
                         sVALUE2             => '50',
                         sBACKCOLOR          => '#99FF00',
                         nBORDERTOPWEIGHT    => 1,       -- Верхняя граница ячейки, толщина (если 0, то не формируется)
                         nBORDERBOTTOMWEIGHT => 1,       -- Нижняя граница ячейки, толщина (если 0, то не формируется)
                         nBORDERLEFTWEIGHT   => 1,       -- Левая граница ячейки, толщина (если 0, то не формируется)
                         nBORDERRIGHTWEIGHT  => 1 );     -- Правая граница ячейки, толщина (если 0, то не формируется)


    -- значение ячейки больше
    ADD_CONDFORMAT_XLSX( sCONDFORMAT         => 'cellIs2',
                         sCONDTYPE           => 'cellIs',
                         sOPERATOR           => 'greaterThan',
                         sVALUE1             => '50',
                         sBACKCOLOR          => '#99FFCC',
                         sFONTCOLOR          => '#FF0000' );

    -- ***********************************************************************************
    -- открываем лист
    APKG_XLSREP.OPEN_SHEET
    (
      nPROTECTED        => 0,           -- Защищенный лист
      sDATA             => '',          -- Данные о листе
      nHSTATICCELLS     => 3,           -- Количество заголовочных ячеек
      nVSTATICCELLS     => 4,
      nOPTIMIZE_INSERT  => 0            -- Оптимизация добавления ячеек
    );

    -- открываем табличную область
    APKG_XLSREP.OPEN_TABLE();

    -- Колонка 1
    APKG_XLSREP.ADD_COLUMN( nWIDTH => 200 );
    -- Колонка 2
    APKG_XLSREP.ADD_COLUMN( nWIDTH => 200 );
    -- Колонки с суммами (6 шт)
    APKG_XLSREP.ADD_COLUMN( nWIDTH => 70, nCOUNT => 6 );

    -- Строка - заголовок
    APKG_XLSREP.ADD_ROW;
    nROWHEAD1 := APKG_XLSREP.GET_CUR_ROW;
    APKG_XLSREP.ADD_ROW;
    nROWHEAD2 := APKG_XLSREP.GET_CUR_ROW;
    APKG_XLSREP.ADD_ROW;
    nROWHEAD3 := APKG_XLSREP.GET_CUR_ROW;

    -- Заголовок 1-2 колонки
    APKG_XLSREP.ADD_CELL( sCELLDATA  => 'Показатели/Услуги/Отчетные года',
                          sCELLTYPE  => 'String',
                          nROWNUMBER => nROWHEAD1,
                          sSTYLE     => 'head_tab',
                          nMERGEDOWN => 2,              -- Сколько ячеек присоединить снизу
                          nMERGEACROSS => 1 );          -- Сколько ячеек присоединить справа
    -- добавляем пустые ячейки в объединяемую область
    APKG_XLSREP.ADD_CELL( sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD2, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD2, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );

    -- Заголовок 3-4 колонки
    APKG_XLSREP.ADD_CELL( sCELLDATA  => 'Периоды планирования',
                          sCELLTYPE  => 'String',
                          nROWNUMBER => nROWHEAD1,
                          sSTYLE     => 'head_tab',
                          nMERGEDOWN => 1,              -- Сколько ячеек присоединить снизу
                          nMERGEACROSS => 1 );          -- Сколько ячеек присоединить справа
    -- добавляем пустые ячейки в объединяемую область
    APKG_XLSREP.ADD_CELL( sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD2, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD2, sSTYLE => 'head_tab' );

    APKG_XLSREP.ADD_CELL( sCELLDATA  => '2014', sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLDATA  => '2015', sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );

    -- Заголовок 5-8 колонки
    APKG_XLSREP.ADD_CELL( sCELLDATA  => 'Периоды контроля',
                          sCELLTYPE  => 'String',
                          nROWNUMBER => nROWHEAD1,
                          sSTYLE     => 'head_tab',
                          nMERGEACROSS => 3 );
    APKG_XLSREP.ADD_CELL( sCELLDATA  => 'План',
                          sCELLTYPE  => 'String',
                          nROWNUMBER => nROWHEAD2,
                          sSTYLE     => 'head_tab',
                          nMERGEACROSS => 1 );
    APKG_XLSREP.ADD_CELL( sCELLDATA  => 'Факт',
                          sCELLTYPE  => 'String',
                          nROWNUMBER => nROWHEAD2,
                          sSTYLE     => 'head_tab',
                          nMERGEACROSS => 1 );

    APKG_XLSREP.ADD_CELL( sCELLDATA  => '2014', sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLDATA  => '2015', sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLDATA  => '2014', sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );
    APKG_XLSREP.ADD_CELL( sCELLDATA  => '2015', sCELLTYPE  => 'String', nROWNUMBER => nROWHEAD3, sSTYLE => 'head_tab' );

    -- данные
    APKG_XLSREP.ADD_ROW;
    APKG_XLSREP.ADD_CELL( sCELLDATA => 'Показатель1', sCELLTYPE => 'String', sSTYLE => 'cell', nMERGEDOWN => 2 );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 'Услуга1_1',   sCELLTYPE => 'String', sSTYLE => 'cell' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 1,             sCELLTYPE => 'Number', sCONDFORMAT => 'cscale3' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 28,            sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs1' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs2' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sSTYLE => 'cell_num' );

    APKG_XLSREP.ADD_ROW;
    APKG_XLSREP.ADD_CELL( sCELLTYPE => 'String', sSTYLE => 'cell' ); -- описание пустой ячейки
    APKG_XLSREP.ADD_CELL( sCELLDATA => 'Услуга1_2',   sCELLTYPE => 'String', sSTYLE => 'cell' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 20,            sCELLTYPE => 'Number', sCONDFORMAT => 'cscale3' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sSTYLE => 'cell_num', sCONDFORMAT => 'cellIs1' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sSTYLE => 'cell_num', sCONDFORMAT => 'cellIs2' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sSTYLE => 'cell_num' );

    APKG_XLSREP.ADD_ROW;
    APKG_XLSREP.ADD_CELL( sCELLTYPE => 'String', sSTYLE => 'cell' ); -- описание пустой ячейки
    APKG_XLSREP.ADD_CELL( sCELLDATA => 'Услуга1_3',   sCELLTYPE => 'String', sSTYLE => 'cell' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 5,             sCELLTYPE => 'Number', sCONDFORMAT => 'cscale3' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs1' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs2' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    --
    APKG_XLSREP.ADD_ROW;
    APKG_XLSREP.ADD_CELL( sCELLDATA => 'Показатель2', sCELLTYPE => 'String', sSTYLE => 'cell', nMERGEDOWN => 1 );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 'Услуга2_1',   sCELLTYPE => 'String', sSTYLE => 'cell' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 15,            sCELLTYPE => 'Number', sCONDFORMAT => 'cscale3' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 10,            sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs1' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs2' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sSTYLE => 'cell_num' );

    APKG_XLSREP.ADD_ROW;
    APKG_XLSREP.ADD_CELL( sCELLTYPE => 'String', sSTYLE => 'cell' ); -- описание пустой ячейки
    APKG_XLSREP.ADD_CELL( sCELLDATA => 'Услуга2_2',   sCELLTYPE => 'String', sSTYLE => 'cell' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 8,             sCELLTYPE => 'Number', sCONDFORMAT => 'cscale3' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 20,            sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs1' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sCONDFORMAT => 'cellIs2' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 0,             sCELLTYPE => 'Number', sSTYLE => 'cell_num' );
    APKG_XLSREP.ADD_CELL( sCELLDATA => 100,           sCELLTYPE => 'Number', sSTYLE => 'cell_num' );


    -- выгружаем сформированные строки и столбцы
    APKG_XLSREP.FLUSH_ROWCELLS();

    -- закрываем табличную область и лист
    APKG_XLSREP.CLOSE_TABLE_AND_SHEET();

    -- закрываем отчет
    APKG_XLSREP.CLOSE_REPORT();

    oBLOB := APKG_XLSREP.GET_BLOB;

  exception
    when others then
      APKG_XLSREP.FREE_BLOB();
      raise;
  end;


end;
​
