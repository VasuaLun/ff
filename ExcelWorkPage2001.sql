declare
    nSUPPORT_SIGN number(17);
BEGIN
    htp.p('<style>
  .vertical-images-list a {font-weight: bold; text-decoration: none; display:block;}
  .vertical-images-list a:hover {text-decoration:underline;}
        </style>');

  htp.p('<div class="vertical-images-list">');


			htp.p('<div style=" background: url(''/i/menu/spreadsheet_32.gif'') no-repeat center left; background-size: 32px; margin-top:0px;margin-bottom:10px; line-height:17px; margin-left:0px; padding-left: 40px; padding-top: 10px; padding-bottom:10px;">

					<a href="#" onclick="ShowReport(''DV_TESTPROC_HEAD'', ''Паспорт учреждения'', ''APXWS''); return false">
					Паспорт учреждения
					</a> </div>
					');
			htp.p();


    htp.p('<div class="clear"></div></div>');
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
