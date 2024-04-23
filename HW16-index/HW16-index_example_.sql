--Examples 
-- Список работающих сотрудников на дату 
Select p.pid "Таб. номер", c.Full_Name "ФИО сотрудника", a.name_app "Должность", s.struct_code,  s.struct_name "Подразделение", cel.wage "Оклад", p.date_in "Дата приема", o.Order_name "Приказ о приёме",  p.date_out "Дата увольнения"
From People p
left outer join Card c on c.auto_card = p.auto_card
left outer join pr_current pr on pr.pid = p.pid and GETDATE() between pr.date_start and pr.date_end
left outer join Cells Cel on Cel.Cell_id = pr.Cell_id
left outer join Appoints a on a.app_code = Cel.app_code
left outer join Structs s on s.struct_code = Cel.Struct_code
left outer join Orders o on o.Order_id = p.Order_id
where getdate() between p.date_in and p.date_out
	and p.firm_id = 1
--события за месяц
Select pid from People where date_in between '2023-01-01' and '2023-01-31' or  date_out between '2023-01-01' and '2023-01-31'
--ШР
Select ISNULL(f.Name, '- По всем фирмам') "Фирма", ISNULL(s.struct_name, '- По всем подразделениям') "Подразделение", ISNULL(a.name_app, '- По всем должностям') "Должность", ISNULL(cel.wage, 0) "Оклад", SUM(Cel.number_count) "Кол ставок", SUM(Cel.number_used) "Ставок занято", SUM(Cel.number_count) - SUM(Cel.number_used) "Вакансий"
From 
Cells Cel 
left outer join Appoints a on a.app_code = Cel.app_code
left outer join Structs s on s.struct_code = Cel.Struct_code
left outer join Firms f on f.firm_id = cel.firm_id
where Cel.firm_id = 1
GROUP BY f.Name, s.struct_name , a.name_app , cel.wage with rollup
ORDER BY 1, 2, 3, 4

-- РЛ
Select  'Таб №' + convert(varchar(5), p.pid) + ' ' + c.Full_Name + ' ' + a.name_app + ' ' + s.struct_name + ' Оклад:' + convert(varchar(25), cast(cel.wage AS numeric(16,0))) as wage,
	case when ttt.cp = 999 then 'Всего ' + ttt.t else '  (' + convert(varchar(3), ttt.cp) + ') ' + isnull(tp.Name_pay, 'К выдаче ') end as tp, round(ttt.summa, 2)
from (
Select t, pid, case GROUPING(cp) when 1 then 999 else cp end as cp ,
SUM(summa) as summa
from  (
Select '1 Начислено' as t, l.pid as pid, 
	L.code_pay as cp,
	round(SUM(L.summa), 2) as summa
From Lic L
where l.cmonth = 2023*12+12
	and L.code_pay < 100
group by l.pid, L.code_pay
union all
Select '2 Удержано'as t, l.pid as pid, 
	L.code_pay as cp,
	round(SUM(L.summa), 2) as summa
From Lic L
where l.cmonth = 2023*12+12
	and L.code_pay >= 100
group by l.pid, L.code_pay
union all
Select '3 К выдаче' as t, l.pid as pid, 
	300 as cp,
	SUM(L.summa) -  MAX(t.summa) as summa
From Lic L
cross apply(select SUM(summa) summa from Lic l1 where l1.pid = L.pid and l1.cmonth = l.cmonth and l1.code_pay >=100) as t 
where l.cmonth = 2023*12+12 
	and L.code_pay < 100
group by l.pid
) as tt

group by rollup (t, pid, cp)
having pid is not null and  t is not null

) as ttt

	left outer join People p  on p.pid = ttt.pid
	left outer join Card c on c.auto_card = p.auto_card
	left outer join pr_current pr on pr.pid = p.pid 
	left outer join Cells Cel on Cel.Cell_id = pr.Cell_id
	left outer join Appoints a on a.app_code = Cel.app_code
	left outer join Structs s on s.struct_code = Cel.Struct_code
	left outer join [dbo].[Typ_pay] tp on tp.Code_pay = ttt.cp

order by 1, ttt.t, 2

--Свод по ВО за месяц

Select case GROUPING(t) WHEN 1 THEN 'Всего Выплачено'  else  (
CASE GROUPING(tp) WHEN 1 THEN 'Всего ' + ' ' + t else '   ' + tp end) end as type_groupind1,
SUM(summa) as summa
from (
	select  'Начислено' t,  tp.name_pay tp, SUM(summa) summa
		from lic l
		left outer join [dbo].[Typ_pay] tp on tp.Code_pay = L.code_pay
	where l.cmonth between 2023*12+1 and 2023*12+1
	and L.code_pay < 100
	group by  tp.name_pay
	union all
	select  'Удержано' t,  tp.name_pay tp, SUM(summa)*-1 summa
		from lic l
		left outer join [dbo].[Typ_pay] tp on tp.Code_pay = L.code_pay
	where l.cmonth between 2023*12+1 and 2023*12+1 
	and L.code_pay >= 100
	group by  tp.name_pay
) as tt
group by rollup (t, tp)
--having t is not null
order by t, tp

-- поиск в списках по подстроке
select name, name_i, name_o from card where name_i like 'Иван'
--
select app_code from Appoints where name_app like 'Менедж%'