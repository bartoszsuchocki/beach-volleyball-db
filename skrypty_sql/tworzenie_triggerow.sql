	/*Tworzenie triggerów*/

/**---Na insert---**/

/*Podczas dodawania wyniku meczu, sprawdzenie czy nie wpisano dwóch takich samych dru¿yn bior¹cych w nim udzia³. 
Jeœli tak siê sta³o, wynik meczu nie zostanie dodany.*/
create trigger dodawanie_mecz_dwie_rozne_druzyny_sprawdzenie
on Mecz for insert
as
if exists(
	select 1
	from inserted i
	where i.druzyna_1=i.druzyna_2
)
begin
print 'Druzyna nie moza grac sama przeciwko sobie!'
rollback tran
end
go

/*---Na insert,update---*/

/*Przy dodawaniu zawodnika do dru¿yny lub zmienianie jego dru¿yny, 
sprawdzenie czy dru¿yna nie ma ju¿ 2 (max. iloœæ) zawodników. Jeœli ma, nie pozwoliæ na dodanie/zmianê.*/
create trigger zawodnik_do_druzyny_sprawdzenie
on Zawodnik
for insert,update
as
	select top 1 count(*) as [Ilosc],d.id, d.nazwa into #najliczniejsza
	from Druzyna d
	join inserted i
		on i.id_druzyna = d.id
	join Zawodnik z
		on z.id_druzyna = d.id
	group by d.id, d.nazwa
	order by [Ilosc] desc

if (select Ilosc from #najliczniejsza) > 2
begin
	declare @nazwa nvarchar(40)
	set @nazwa = (select nazwa from #najliczniejsza)
	print 'Druzyna '+@nazwa+' ma juz maksymalna liczbe zawodnikow!'
	rollback tran
end
go

/*Przy dodawaniu wyników meczu (wiersza do tabeli Mecz) lub zmianie rekordu w tabeli Mecz,
 sprawdzenie czy data rozegrania meczu nie jest póŸniejsza ni¿ data koñca turnieju.
  Jeœli jest, rekord nie zostanie dodany/zmieniony. */
create trigger mecz_sprawdzenie_daty
on Mecz for insert, update
as
if exists(select 1 from Mecz m
join inserted i
	on m.id = i.id
join Turniej t
	on m.id_turniej = t.id
where i.data > t.data_konca)
begin
	print 'Nie mozna dodawac meczu rozegranego po zakonczeniu turnieju!'
	rollback tran
end
go
/*---Na update---*/

/*Przy modyfikacji którejœ nagrody w rekordzie tabeli Turniej, 
sprawdzenie czy turniej ju¿ siê nie zacz¹³ (jeœli tak, zmiana bêdzie mo¿liwa 
tylko w przypadku zwiêkszenia nagrody).*/
create trigger edycja_nagrody_sprawdzenie
on Turniej for update
as
update Turniej set pierwsze_miejsce=d.pierwsze_miejsce
from Turniej t 
join inserted i
	on t.id = i.id
join deleted d
	on t.id = d.id
where d.pierwsze_miejsce>i.pierwsze_miejsce and (SELECT CONVERT(date, getdate()))>t.data_rozpoczecia

update Turniej set drugie_miejsce=d.drugie_miejsce
from Turniej t 
join inserted i
	on t.id = i.id
join deleted d
	on t.id = d.id
where d.drugie_miejsce>i.drugie_miejsce and (SELECT CONVERT(date, getdate()))>t.data_rozpoczecia

update Turniej set trzecie_miejsce=d.trzecie_miejsce
from Turniej t 
join inserted i
	on t.id = i.id
join deleted d
	on t.id = d.id
where d.trzecie_miejsce>i.trzecie_miejsce and (SELECT CONVERT(date, getdate()))>t.data_rozpoczecia


go

/*Przy modyfikacji sk³adu dru¿yny (zmiana id_dru¿yny w rekordzie tabeli Zawodnik), 
sprawdzenie czy dana dru¿yna bierze udzia³ w trwaj¹cym ju¿ turnieju 
(czy rozegra³a ju¿ przynajmniej jeden mecz). Jeœli tak, zmiana nie bêdzie mo¿liwa. */
create trigger edycja_skladu_druzyny_sprawdzenie
on Zawodnik for update
as
if exists(
select 1
from Zawodnik z
join inserted i
	on z.pesel = i.pesel
join deleted d
	on z.pesel = d.pesel
where i.id_druzyna!=d.id_druzyna
and exists (select 1 
		from Mecz m
		join Turniej t on m.id_turniej = t.id 
		where t.data_konca>(select convert(date,getdate())) 
		and (m.druzyna_1=d.id_druzyna or m.druzyna_2=d.id_druzyna)
		)
)
begin
print 'Nie mozna zmieniac skladu druzyny grajacej w trwajacym turnieju!'
rollback tran
end

go

/*---Na delete---*/

/*Przy usuwaniu turnieju, sprawdzenie czy ju¿ trwa. Jeœli tak, usuniêcie nie bêdzie mo¿liwe. */
create trigger usuwanie_turniej_sprawdzenie
on Turniej for delete
as
if exists(
	select 1 
	from deleted d
	where (select convert(date,getdate())) between d.data_rozpoczecia and d.data_konca
	)
begin
print 'Nie mozna usunac trwajacego turnieju!'
rollback tran
end
go

/*Podczas usuwania zawodnika, sprawdzenie czy jego dru¿yna nie bierze udzia³u w trwaj¹cym turnieju. 
Jeœli bierze, usuwanie siê nie powiedzie.*/
create trigger usuwanie_zawodnik_sprawdzenie
on Zawodnik for delete
as
if exists (
	select *
	from deleted d
	join Mecz m
		on d.id_druzyna=m.druzyna_1 or d.id_druzyna=m.druzyna_2
	join Turniej t
		on m.id_turniej = t.id
	where (select convert(date,getdate())) between t.data_rozpoczecia and t.data_konca
)
begin
print 'Nie mozna usunac zawodnika, ktorego druzyna bierze udzial w trwajacym turnieju!'
rollback tran 
end
go