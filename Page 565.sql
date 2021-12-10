begin
	if ((:P565_PART is null) or (:P565_PART = 1)) then

		-- СЛОВАРИ ОБЩИЕ
		if :P565_SUBPART is null or :P565_SUBPART = 1 then

			ZP_DICTGEN_COPY (pVERSFROM   => :P565_VERSION_FROM,
							 pVERSTO     => :P565_VERSION_TO,
							 pTYPEACTION => :P565_TYPEACTION,
                             pTABLE      => :P565_DICTGEN_TABLE);
		end if;

		-- СЛОВАРИ ОРГАНИЗАЦИЙ
		if :P565_SUBPART is null or :P565_SUBPART = 2 then
			ZP_DICTORG_COPY (pVERSFROM   => :P565_VERSION_FROM,
							 pVERSTO     => :P565_VERSION_TO,
							 pTYPEACTION => :P565_TYPEACTION,
                             pTABLE      => :P565_DICTORG_TABLE);
		end if;

		-- СЛОВАРИ УСЛУГ
		if :P565_SUBPART is null or :P565_SUBPART = 3 then
			ZP_DICTSERV_COPY (pVERSFROM   => :P565_VERSION_FROM,
							  pVERSTO     => :P565_VERSION_TO,
							  pTYPEACTION => :P565_TYPEACTION,
							  pTABLE      => :P565_DICTSERV_TABLE);
		end if;

		-- СЛОВАРИ ПОКАЗАТЕЛЕЙ
		if :P565_SUBPART is null or :P565_SUBPART = 4 then
			ZP_DICTIND_COPY (pVERSFROM   => :P565_VERSION_FROM,
							 pVERSTO     => :P565_VERSION_TO,
							 pTYPEACTION => :P565_TYPEACTION,
                             pTABLE      => :P565_DICTIND_TABLE);
		end if;

		-- СЛОВАРИ КБК
		if :P565_SUBPART is null or :P565_SUBPART = 5 then
			ZP_DICTKBK_COPY (pVERSFROM   => :P565_VERSION_FROM,
							 pVERSTO     => :P565_VERSION_TO,
							 pTYPEACTION => :P565_TYPEACTION,
							 pTABLE      => :P565_DICTKBK_TABLE);
		end if;

		-- СЛОВАРИ ЦС
		if :P565_SUBPART is null or :P565_SUBPART = 6 then
			ZP_DICTFUNDS_COPY (pVERSFROM   => :P565_VERSION_FROM,
							   pVERSTO     => :P565_VERSION_TO,
							   pTYPEACTION => :P565_TYPEACTION,
							   pTABLE      => :P565_DICTFUNDS_TABLE);
		end if;

		-- СЛОВАРИ ГРУППЫ РЕСУРСЫ
		if :P565_SUBPART is null or :P565_SUBPART = 7 then
			ZP_DICTRES_COPY (pVERSFROM   => :P565_VERSION_FROM,
							 pVERSTO     => :P565_VERSION_TO,
                             pTYPEACTION => :P565_TYPEACTION,
                             pTABLE      => :P565_DICTRES_TABLE);
		end if;

		-- СЛОВАРИ СТРУКТУРЫ ДОХОДОВ
		if :P565_SUBPART is null or :P565_SUBPART = 8 then
			ZP_DICTINCOME_COPY (pVERSFROM   => :P565_VERSION_FROM,
								pVERSTO     => :P565_VERSION_TO,
								pTYPEACTION => :P565_TYPEACTION,
								pTABLE      => :P565_DICTINCOME_TABLE);
		end if;

		-- СЛОВАРИ СТРУКТУРЫ ЗАТРАТ
		if :P565_SUBPART is null or :P565_SUBPART = 9 then
			ZP_DICTEXPMAT_COPY (pVERSFROM   => :P565_VERSION_FROM,
								pVERSTO     => :P565_VERSION_TO,
                                pTYPEACTION => :P565_TYPEACTION,
                                pTABLE      => :P565_DICTEXPMAT_TABLE);
		end if;

		--СЛОВАРИ БАЗОВЫЕ НОМРАТИВЫ
		if :P565_SUBPART is null or :P565_SUBPART = 10 then
			ZP_DICTBASENORM_COPY (pVERSFROM   => :P565_VERSION_FROM,
								  pVERSTO     => :P565_VERSION_TO,
                                  pTYPEACTION => :P565_TYPEACTION,
                                  pTABLE      => :P565_DICTBASENORM_TABLE);
		end if;

		-- СЛОВАРИ ГРУППЫ КОНТРОЛЯ
		if :P565_SUBPART is null or :P565_SUBPART = 11 then
			ZP_DICTCTRLGR_COPY (pVERSFROM   => :P565_VERSION_FROM,
								pVERSTO     => :P565_VERSION_TO,
                                pTYPEACTION => :P565_TYPEACTION,
                                pTABLE      => :P565_DICTCTRLGR_TABLE);
		end if;

		-- СЛОВАРИ ГРУППЫ ПФХД
		if :P565_SUBPART is null or :P565_SUBPART = 12 then
			ZP_DICTPFHD_COPY (pVERSFROM   => :P565_VERSION_FROM,
							  pVERSTO     => :P565_VERSION_TO,
                              pTYPEACTION => :P565_TYPEACTION,
                              pTABLE      => :P565_DICTPFHD_TABLE,
							  pTYPEREP    => null);
		end if;

		-- СЛОВАРИ ОБОСНОВАНИЙ
		if :P565_SUBPART is null or :P565_SUBPART = 13 then
			ZP_JUSTIFYDICT_COPY (pVERSFROM   => :P565_VERSION_FROM,
								 pVERSTO     => :P565_VERSION_TO,
                                 pTYPEACTION => :P565_TYPEACTION,
                                 pTABLE      => :P565_JUSTIFYDICT_TABLE);
		end if;

	end if;


	if ((:P565_PART is null) or (:P565_PART = 2)) then

		ZP_SERVREG_COPY (pVERSFROM   => :P565_VERSION_FROM,
						 pVERSTO     => :P565_VERSION_TO,
						 pTYPEACTION => :P565_TYPEACTION,
					     pTABLE      => :P565_SERVREG_TABLE);
	end if;


	if ((:P565_PART is null) or (:P565_PART = 3)) then
		ZP_ORGREG_COPY (pVERSFROM   => :P565_VERSION_FROM,
						pVERSTO     => :P565_VERSION_TO,
						pORGRNFROM  => :P565_ORGRN_FROM,
						pORGRNTO    => :P565_ORGRN_TO,
                        pTYPEACTION => :P565_TYPEACTION,
                        pTABLE      => :P565_ORGREG_TABLE);
	end if;


	if ((:P565_PART is null) or (:P565_PART = 4)) then

		ZP_LINKS_COPY (pVERSFROM   => :P565_VERSION_FROM,
					   pVERSTO     => :P565_VERSION_TO,
					   pORGRNFROM  => :P565_ORGRN_FROM,
					   pORGRNTO    => :P565_ORGRN_TO,
					   pTYPEACTION => :P565_TYPEACTION);
	end if;

	--ЗАТРАТЫ
	if ((:P565_PART is null) or (:P565_PART = 8)) then
		if :P565_SUBPART is null or :P565_SUBPART = 1 then
			ZP_DISTR_COPY(pVERSFROM   => :P565_VERSION_FROM,
						   pVERSTO     => :P565_VERSION_TO,
						   pORGRNFROM  => :P565_ORGRN_FROM,
						   pORGRNTO    => :P565_ORGRN_TO,
						   pTYPEACTION => :P565_TYPEACTION,
						   pTABLE      => :P565_DICTEXPBUDG_TABLE,
						   pHIST	   => :P565_HIST,
						   pPERIODFROM => :P565_PERIOD_FROM,
						   pPERIODTO   => :P565_PERIOD_TO);
		end if;

		if :P565_SUBPART is null or :P565_SUBPART = 2 then
			ZP_EXPKAZ_COPY(pVERSFROM   => :P565_VERSION_FROM,
						   pVERSTO     => :P565_VERSION_TO,
						   pORGRNFROM  => :P565_ORGRN_FROM,
						   pORGRNTO    => :P565_ORGRN_TO,
						   pTYPEACTION => :P565_TYPEACTION,
						   pHIST	   => :P565_HIST);
		end if;

		if :P565_SUBPART is null or :P565_SUBPART = 3 then
			ZP_DISTR_RES_COPY(pVERSFROM   => :P565_VERSION_FROM,
						   pVERSTO     => :P565_VERSION_TO,
						   pORGRNFROM  => :P565_ORGRN_FROM,
						   pORGRNTO    => :P565_ORGRN_TO,
						   pTYPEACTION => :P565_TYPEACTION,
						   pTABLE      => :P565_DICTEXPRES_TABLE);
		end if;
	end if;


	--ДОХОДЫ
	if ((:P565_PART is null) or (:P565_PART = 7)) then
		if :P565_SUBPART is null or :P565_SUBPART = 1 then
			ZP_BUDGDETAIL_COPY(pVERSFROM   => :P565_VERSION_FROM,
						   pVERSTO     => :P565_VERSION_TO,
						   pORGRNFROM  => :P565_ORGRN_FROM,
						   pORGRNTO    => :P565_ORGRN_TO,
						   pTYPEACTION => :P565_TYPEACTION,
						   pHIST	   => :P565_HIST);
		end if;

		if :P565_SUBPART is null or :P565_SUBPART = 2 then
			ZP_VBDETAIL_COPY(pVERSFROM   => :P565_VERSION_FROM,
						   pVERSTO     => :P565_VERSION_TO,
						   pORGRNFROM  => :P565_ORGRN_FROM,
						   pORGRNTO    => :P565_ORGRN_TO,
						   pTYPEACTION => :P565_TYPEACTION,
						   pHIST	   => :P565_HIST);
		end if;

		if :P565_SUBPART is null or :P565_SUBPART = 3 then
			ZP_RESTDETAIL_COPY(pVERSFROM   => :P565_VERSION_FROM,
						   pVERSTO     => :P565_VERSION_TO,
						   pORGRNFROM  => :P565_ORGRN_FROM,
						   pORGRNTO    => :P565_ORGRN_TO,
						   pTYPEACTION => :P565_TYPEACTION,
						   pHIST	   => :P565_HIST);
		end if;
	end if;

	--ЗАКУПКИ
	if ((:P565_PART is null) or (:P565_PART = 5)) then

		ZP_PURCHASES_COPY (pVERSFROM  => :P565_VERSION_FROM,
						   pVERSTO    => :P565_VERSION_TO,
						   pORGRNFROM => :P565_ORGRN_FROM,
						   pORGRNTO   => :P565_ORGRN_TO,
						   pTYPEACTION => :P565_TYPEACTION,
						   pHIST       => :P565_HIST);

	end if;


	if ((:P565_PART is null) or (:P565_PART = 6)) then

		ZP_QIND_COPY (pVERSFROM   => :P565_VERSION_FROM,
					  pVERSTO     => :P565_VERSION_TO,
					  pORGRNFROM  => :P565_ORGRN_FROM,
					  pORGRNTO    => :P565_ORGRN_TO,
					  pTYPEACTION => :P565_TYPEACTION,
					  pHIST       => :P565_HIST);
	end if;

	--ОБОСНОВАНИЯ РАСХОДОВ
	if ((:P565_PART is null) or (:P565_PART = 11 and :P565_SUBPART = 2)) then
		ZP_JUSTIFY_COPY (pVERSFROM   => :P565_VERSION_FROM,
						 pVERSTO     => :P565_VERSION_TO,
						 pORGRNFROM  => :P565_ORGRN_FROM,
						 pORGRNTO    => :P565_ORGRN_TO,
                         pTYPEACTION => :P565_TYPEACTION,
						 pFORMNUM    => :P565_FORMNUM,
						 pPERIODFROM => :P565_PERIOD_FROM,
						 pPERIODTO   => :P565_PERIOD_TO);
	end if;

	--ОБОСНОВАНИЯ ДОХОДОВ
	if ((:P565_PART is null) or (:P565_PART = 11 and :P565_SUBPART = 1)) then

		ZP_JUSTIFY_INCOME_COPY (pVERSFROM   => :P565_VERSION_FROM,
						 pVERSTO     => :P565_VERSION_TO,
						 pORGRNFROM  => :P565_ORGRN_FROM,
						 pORGRNTO    => :P565_ORGRN_TO,
                         pTYPEACTION => :P565_TYPEACTION,
						 pFORMNUM    => :P565_INCOME_FORMNUM,
						 pPERIODFROM => :P565_PERIOD_FROM,
						 pPERIODTO   => :P565_PERIOD_TO);
	end if;

	--ОБОСНОВАНИЯ - ПОСТАВЩИКИ
	if ((:P565_PART is null) or (:P565_PART = 11 and :P565_SUBPART = 3)) then

		ZP_JUSTIFY_PROVIDERS_COPY (pVERSFROM   => :P565_VERSION_FROM,
								   pVERSTO     => :P565_VERSION_TO,
								   pORGRNFROM  => :P565_ORGRN_FROM,
								   pORGRNTO    => :P565_ORGRN_TO,
								   pTYPEACTION => :P565_TYPEACTION);
	end if;

	--ОБОСНОВАНИЯ - ПРИМЕНИМОСТЬ СПРАВОЧНИКА JLOV К УЧРЕЖДЕНИЯМ
	if ((:P565_PART is null) or (:P565_PART = 11 and :P565_SUBPART = 4)) then

		ZP_JUSTIFY_JLOV_ORGS_COPY (pVERSFROM   => :P565_VERSION_FROM,
								   pVERSTO     => :P565_VERSION_TO,
								   pORGRNFROM  => :P565_ORGRN_FROM,
								   pORGRNTO    => :P565_ORGRN_TO,
								   pTYPEACTION => :P565_TYPEACTION);
	end if;

	-- СПОРТ - УЧАСТНИКИ
	if (:P565_PART is null) or (:P565_PART = 12 and :P565_SUBPART = 2) then

		ZP_SPORT_COPY (pVERSFROM   => :P565_VERSION_FROM,
					   pVERSTO     => :P565_VERSION_TO,
					   pORGRNFROM  => :P565_ORGRN_FROM,
					   pORGRNTO    => :P565_ORGRN_TO,
					   pTABLE      => 'Z_SPORT_MEMBER',
					   pTYPEACTION => :P565_TYPEACTION);
	end if;

	-- СПОРТ - КОМАНДЫ
	if (:P565_PART is null) or (:P565_PART = 12 and :P565_SUBPART = 1) then

		ZP_SPORT_COPY (pVERSFROM   => :P565_VERSION_FROM,
					   pVERSTO     => :P565_VERSION_TO,
					   pORGRNFROM  => :P565_ORGRN_FROM,
					   pORGRNTO    => :P565_ORGRN_TO,
					   pTABLE      => 'Z_SPORT_TEAM',
					   pTYPEACTION => :P565_TYPEACTION);
	end if;

end;
