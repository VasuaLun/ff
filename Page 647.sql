-- Page 647
declare
  count_rows   number := 0;
  pJURPERS     number := :P1_JURPERS;
  pVERSION     number := :P1_VERSION;  
  pORGRN	   number := nvl(:P1_ORGRN,:P7_ORGFILTER);
  pLIBDET_RN   number := :P647_LIBDET_RN;
  pEXIST       number := :P647_EXIST;
  pERRTYPE     number := :P647_ERRTYPE;
  sExists      varchar(250); 
  sOPTIONS     varchar(2500); 
begin
    htp.p('<style>
     .report_standard tbody tr:hover td {
           background-color: #FFFAF0; color: #000;
           cursor: pointer;
        }
    .report_standard  thead > tr {width: 100%; }
    .report_standard  tbody > tr {width: 100%; display: block}
    .report_standard > tbody {
        display: block; height: 300px; overflow-x: hidden;  overflow-y: scroll;
      }
    .report_standard  tbody::-webkit-scrollbar {
              width: 16px!important
          }

    .report_standard  tbody::-webkit-scrollbar-thumb {
              background-color: rgb(195, 195, 195);
              border-radius: 20px;
              border: 3px solid rgba(255, 255, 255, 1);
          }

    .report_standard  tbody::-webkit-scrollbar-track {
             background: rgba(255, 255, 255, 1);
          }
    .sub_td {padding:0;margin:0; border:none;}

    .sub_region {
      width:100%;
    }
    .sub_region  {
      
    }

    .report_standard thead {
      display: block; width:100%
    }
    .report_standard{
      border: 1px solid grey;
    }

    .report_standard th, td{
      text-align:left;
    }
    .report_standard th{
      text-align:center;
    }
    .report_standard th {
      color:#222;
      font: bold 12px/12px Arial, sans-serif;
      text-shadow: 0 1px 0 rgba(255, 255, 255, 0.5);
      padding: 4px 4px;
       /* background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 50% #e1e1e1 repeat-x;*/
      background: #e1e1e1;
      border-bottom: 1px solid #9fa0a0;
      border-left:1px solid #9fa0a0;
    }
    .report_standard td{
      padding: 4px 4px;
      border-bottom: 1px solid #9fa0a0;
      background-color: #f2f2f2;
    }

    .in_txt {width:70px; border: 1px solid #ccc;text-align:right;}

    .link_code {font-weight: bold; color:#0000ff;}
    .row { margin-bottom: 5px;}

    .th0{width: auto;text-align:center;}     .c0 {width: auto; word-wrap: break-word; text-align:center;}    
    .th1{width: 200px;text-align:center;}    .c1 {width: 200px; word-wrap: break-word; text-align:center;}
    .th2{width: 100%;text-align:center;}     .c2 {width: 100%; word-wrap: break-word; text-align:left;}
    .th3{width: 30px; text-align:center;}    .c3 {width: 30px; word-wrap: break-word;text-align:center;} 
    .th4{width: 30px;text-align:center;}       .c4 {width: 30px; word-wrap: break-word; text-align:center;} 
    .th5{width: 60px;text-align:center;}       .c5 {width: 60px; word-wrap: break-word; text-align:center;} 
	.th6{width: 30px;text-align:center;}       .c6 {width: 30px; word-wrap: break-word; text-align:center;} 

    .selected td {background-color:#C0FFC1;}
    
    .report_standard td.orange {background-color: #FFE8AD;}
    .report_standard td.totals {background-color: #e1e1e1;}

    .pagination {text-align: right;
      border: 1px solid grey;
      margin: 0px;
      
      padding: 5px;
      background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 100% #e1e1e1 repeat-x;cursor:move;
    }
    .pagination li {display: inline; margin-left:5px; font-size: 12px; padding: 2px; cursor:default; }
    .selected_row{padding: 4px 4px;
      border-bottom: 1px solid #9fa0a0;
      background-color: #FAFF82;
    }


    .down.up {
      background: url(/i/themes/theme_21/images/up_arrow.png) no-repeat left center;
      cursor:pointer;
      width:15px;height:15px;
      float:left;
      
    }
    .down {
      background: url(/i/themes/theme_21/images/down_arrow.png) no-repeat left center;
      cursor:pointer;
      width:15px; height:15px;
      float:left; 
    }

    .report_standard .col_milk_lgreen {background:#F4FFEC;font-weight:bold;}   .col_milk_lgreen input {background:#F4FFEC;; border-bottom: 1px solid gray}
    .report_standard .col_milk_pink {background:#FDE9D9}   .col_milk_pink input {background:#FDE9D9; border-bottom: 1px solid gray}
    .report_standard .col_milk_green {background:rgb(175, 255, 136);}  .col_milk_green input {background:rgb(175, 255, 136); border-bottom: 1px solid gray}
    .report_standard .col_milk_yellow {background:#F9F2D0;} .col_milk_yellow input {background:#F9F2D0; border-bottom: 1px solid gray}
    .report_standard .col_milk_white {background:#FFFFFF}  .col_milk_white input {background:#FFFFFF; border-bottom: 1px solid gray}

    </style>


  ');
  
  htp.p('<div><table border="0" id="fix" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%; border-bottom:0px" id="">
    <thead>      
        <tr>
         <th class="header th0"  style="border-left:none;"><div class="th0"><input type="checkbox" onclick="selectAll()"/></div></th>
		 <th class="header th1" ><div class="th1">PART</div></th>
		 <th class="header th2" ><div class="th2">Текст ошибки</div></th>
		 <th class="header th3" ><div class="th3">П</div></th>
		 <th class="header th4" ><div class="th4">В</div></th>
		 <th class="header th5" ><div class="th5">EXPR</div></th>
         <th class="header th6" ><div class="th6">-</div></th>        
       <th class="header" ><div style="width:8px"></div></th>
      </thead>
    <tbody id="fullall">
   ');

	
	
    
    for rec in 
    (
	 select V.RN,
            V.PART, 
            V.ERRTEXT,
            V.CHECK_SIGN,
            (select USE_SIGN from Z_RPT_LIB_DETAIL LD, Z_RPT_LIB_VDK_LINKS LVL where LVL.LIBDET_RN = LD.RN  and LVL.VDK_RN = V.RN and LD.RN = pLIBDET_RN ) USE_SIGN,
            (select COUNT(*) from Z_RPT_LIB_DETAIL LD, Z_RPT_LIB_VDK_LINKS LVL where LVL.LIBDET_RN = LD.RN  and LVL.VDK_RN = V.RN and LD.RN = pLIBDET_RN ) EXIST,
			(select EXPR from Z_RPT_LIB_DETAIL LD, Z_RPT_LIB_VDK_LINKS LVL where LVL.LIBDET_RN = LD.RN  and LVL.VDK_RN = V.RN and LD.RN = pLIBDET_RN ) EXPR		
      from Z_RPT_LIB_VDK V
      where (
               (pEXIST is null)
               or (pEXIST = 1 and EXISTS (select LD.RN from Z_RPT_LIB_DETAIL LD, Z_RPT_LIB_VDK_LINKS LVL where LVL.LIBDET_RN = LD.RN  and LVL.VDK_RN = V.RN and LD.RN = pLIBDET_RN))
               or (pEXIST = 2 and NOT EXISTS (select LD.RN from Z_RPT_LIB_DETAIL LD, Z_RPT_LIB_VDK_LINKS LVL where LVL.LIBDET_RN = LD.RN  and LVL.VDK_RN = V.RN and LD.RN = pLIBDET_RN))
            )
        and (
              (pERRTYPE is null)
              or (ERRTYPE = pERRTYPE)
            )
    )
    loop
	  
		sExists := '';
		if rec.EXIST >0  then		
			sExists := '<img style="width:12px" src="/i/icon_validation.gif" title="Уже внесена">';
		end if;
		
		-- sOPTIONS := '<select onchange="apex.submit({request:this.value,set:{''P674_OPTIONS'':this.value}});" style="float:right; margin-right:5px">';
			
		-- for qOPT in 
		-- (
		-- select '<Все>' NAME, 0 NUM, 0 ORDNUM from dual
		-- union all
		-- select NAME, NUM, ORDNUM 
		-- from Z_LOV 
		-- where PART = 'VDK_EXPR' 
		-- order by ORDNUM  
		-- )
		-- loop
		-- sOPTIONS := sOPTIONS||'<option value="'rec.NUM'" 'case when pOPTIONS = rec.NUM then 'selected="selected"' end'>'rec.NAME'</option>';
		-- end loop;
        
        -- sOPTIONS := sOPTIONS||'</select>';

		sOPTIONS := '<td class="c5 " style="border-left:1px solid #ccc"><div class="c5"><select name="expr_'||rec.rn||'" id="'||rec.rn||'" onchange="selectExpr($(this));" style="float:right; margin-right:5px">';

		-- sOPTIONS := null;
		for qOPT in 
		(
		 select null NAME, null NUM, -1 ORDNUM from dual
		  union all
		 select NAME, NUM, ORDNUM 
		   from Z_LOV 
		  where PART = 'VDK_EXPR' 
		  order by ORDNUM	
		)
		loop
			sOPTIONS := sOPTIONS||'<option value="'||qOPT.NUM ||'" '||case when nvl(qOPT.NUM, -1) = nvl(rec.EXPR, -1) then ' selected ' end ||'>'||qOPT.NAME||'</option>';
		end loop;

		sOPTIONS := sOPTIONS || '</select></div></td>';

		-- zp_exception(0, sOPTIONS);

        htp.p('<tr id="row_'||rec.rn||'" row="'||rec.rn||'">
                  <td class="c0 "><div class="c0" style="text-align:center"><input type="checkbox" value="'||rec.rn||'" id="status_'||rec.rn||'" class="status" onclick="selectChek($(this).val());"/></div></td>
                  <td class="c1 " style="border-left:1px solid #ccc"><div class="c1">'||rec.PART||'</div></td>
				  <td class="c2 " style="border-left:1px solid #ccc"><div class="c2">'||rec.ERRTEXT||'</div></td>
				  <td class="c3 " style="border-left:1px solid #ccc"><div class="c3">'||rec.CHECK_SIGN||'</div></td>
				  <td class="c4 " style="border-left:1px solid #ccc"><div class="c4">'||rec.USE_SIGN||'</div></td>
				  '||sOPTIONS||'				
                  <td class="c6 " style="border-left:1px solid #ccc;border-right:1px solid #ccc"><div class="c6">'||sExists||'</div></td>
                </tr>');
              count_rows := count_rows + 1;
      END LOOP;

      htp.p('</tbody></table></div>');
      htp.p('<ul class="pagination" style="margin:0px">');
      htp.p('<li style="float:right;">Всего записей: <b>'||count_rows||'</b></li>');
      htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
      htp.p('<li style="float:left; " id="save_shtat"></li>');
      htp.p('<li style="clear:both"></li></ul>');    

  
  htp.p('<script>

    $(function(){
      table_body=$("#fullall");
      if (window.screen.height<=1024) {
      table_body.height("410px");
      $(".report_standard").css("width","100%");
      } else {
      table_body.height("410px");
      $(".report_standard").css("width","100%");
      }
        $(".pagination").mousedown(startDrag);
        
          
        function startDrag(e){
            staticOffset = table_body.height() - e.pageY;
            table_body.css("opacity", 0.25);
            $(document).mousemove(performDrag).mouseup(endDrag);
            return false;
          }
       
          function performDrag(e){
            table_body.height(Math.max(32, staticOffset + e.pageY) + "px");
            return false;
          }
       
          function endDrag(e){
            $(document).unbind("mousemove", performDrag).unbind("mouseup", endDrag);
            table_body.css("opacity", 1);
          }
     
      
    });
	
	var Checks = new Map();
	
	Checks.toString = function() {
		  var res = "";
		  this.forEach(function(val, key, map){res += key+"_"+val+","});
		  return res;
   	};
	
	function selectChek(value){
	  var res = "";
	  if (Checks.has(value)){
		Checks.delete(value);
	  } else {
		Checks.set(value, $("#expr_" + value).val());
	  }

	  res = Checks.toString();
	  res = res.substr(0, res.length - 1);
	  
	  console.log("res = " + res);
     $("#P647_RN_ARR").val(res);
    }
	
    function selectAll(){
    var elements = $("input.status");
     for(i in elements) {
      selectChek($(elements[i]).val()); 
      if($(elements[i]).is(":checked")) {
        $(elements[i]).prop("checked",false);
        } else {
        $(elements[i]).prop("checked",true);
        }
     }
    }
	
	function selectExpr(elem){
	  var res = "";
	  var rn = elem.attr("name");
	  
	  if (Checks.has(rn)){
		Checks.set(rn, elem.val());
	  }   

	  console.log(Checks.toString());
	  res = Checks.toString();
	  res = res.substr(0, res.length - 1);
	  
	  $("#P647_RN_ARR").val(res);
	}

$(document).ready(function(){
$("#P647_ADD_EXPMATS").click(function(){
    $("#divLoading").addClass("show");
console.log("asd");
});
});
    </script>');
end;