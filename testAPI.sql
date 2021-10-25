create or replace PROCEDURE DV_DINAMIC_EKZ
(
  pFILE        out BLOB
)
AS
  bPrint      boolean := false;
  sTitle      varchar2(2000);

  Begin
      begin
          APKG_XLSREP.OPEN_REPORT(nTYPE => 1);
          begin  -- styles
              APKG_XLSREP.ADD_STYLE(sSTYLE              => 'border_center_str',
                                    nWRAPTEXT           => 1,
                                    nBORDERTOPWEIGHT    => 1,
                                    nBORDERBOTTOMWEIGHT => 1,
                                    nBORDERLEFTWEIGHT   => 1,
                                    nBORDERRIGHTWEIGHT  => 1,
                                    sHALIGNMENT         => 'Center');
          end;
          begin  -- body
              APKG_XLSREP.OPEN_SHEET(nPROTECTED => 0);
              APKG_XLSREP.ADD_RUNTITLE( sHEADERRIGTH => '&amp;L&amp;&quot;Verdana,Полужирный&quot;&amp;K000000&amp;R&amp;&quot;Verdana,Полужирный&quot;&amp;K00-014Подготовлено в ЭС РАМЗЭС');
              APKG_XLSREP.OPEN_TABLE();

              APKG_XLSREP.ADD_COLUMN(nWIDTH => 300);
              APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
              APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str',  sCELLDATA => 'HEEEEEY', sCELLTYPE => 'String');

              APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str',  sCELLDATA => 'Troooouble', sCELLTYPE => 'String', nMERGEACROSS => 5, nMERGEDOWN => 4);

              APKG_XLSREP.FLUSH_ROWCELLS();
              APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
              APKG_XLSREP.CLOSE_REPORT();
              pFILE := APKG_XLSREP.GET_BLOB;

          end; -- body
      exception when others then
          APKG_XLSREP.CLOSE_REPORT();
          APKG_XLSREP.FREE_BLOB;
         raise;
      end;
  end;​
