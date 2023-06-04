use formativaHogwarts;

-- ETAPA 1

-- Adição do telefone e foto na tabela "usuarios"
alter table usuarios add telefone bigint(13);
alter table usuarios add foto varchar(150);
update usuarios
set telefone = '48156489526' where id = '6';
update usuarios
set foto = 'link_da_foto6' where id = '6';

-- Criação das tabelas

create table status(
	id bigint not null auto_increment,
	condicao enum ('Aberta', 'Em Andamento', 'Concluída', 'Encerrada') not null,
	primary key (id)
);

create table foto (
	id bigint not null auto_increment,
    link_foto varchar(150) not null,
    primary key(id)
);

create table tarefa(
	id bigint not null auto_increment,
    titulo varchar(150) not null,
    descricao varchar(300) not null,
    prazo datetime not null,
    dataInicio datetime default now() not null,
    dataFim datetime null,
    localFK bigint not null,
    solicitanteFK bigint not null,
    fotoFK bigint not null,
    statusFK bigint not null,
    primary key(id),
    foreign key(localFK) references locais(id),
    foreign key(solicitanteFK) references usuarios(id),
    foreign key(fotoFK) references foto(id),
    foreign key(statusFK) references status(id)
);

create table responsavel(
	id bigint not null auto_increment,
    solicitanteFK bigint not null,
    responsavelFK bigint not null,
    tarefaFK bigint not null,
    primary key(id),
    foreign key (solicitanteFK) references usuarios(id),
    foreign key(responsavelFK) references usuarios(id),
    foreign key(tarefaFK) references tarefa(id)
);

create table historico(
	id bigint not null auto_increment,
    comentario varchar(200) not null,
    fotoFK bigint not null,
    tarefaFK bigint not null,
    statusFK bigint not null,
    primary key(id),
    foreign key(fotoFK) references foto(id),
    foreign key(tarefaFK) references tarefa(id),
    foreign key(statusFK) references status(id)
);


-- Adição de dados nas tabelas

insert into status(condicao) values ('Aberta'), ('Em Andamento'),('Concluída'),('Encerrada');

insert into foto(link_foto) values ('linkFoto1'),('linkFoto2'),('linkFoto3'),('linkFoto4'),('linkFoto5'),
('linkFoto6'),('linkFoto7'),('linkFoto8'),('linkFoto9'),('linkFoto10');

insert into tarefa
(titulo, descricao, prazo, dataInicio, localFK, solicitanteFK, fotoFK, statusFK)
values ('Troca de Lâmpada', 'Lâmpada queimada no laboratório de Eletrônica 01 precisa ser trocada',
'2023-06-08', '2023-06-01', 1, 4, 1, 1);

insert into tarefa
(titulo, descricao, prazo, dataInicio, localFK, solicitanteFK, fotoFK, statusFK)
values ('Cabo Rompido', 'Cabo de energia do sistema de som rompido',
'2023-06-05', '2023-06-03', 2, 3, 2, 2);

insert into tarefa
(titulo, descricao, prazo, dataInicio, localFK, solicitanteFK, fotoFK, statusFK)
values ('Ar condicionado com problema', 'Ar condicionado não está funcionando',
'2023-06-15', '2023-06-10', 5, 3, 3, 1);

insert into tarefa
(titulo, descricao, prazo, dataInicio, localFK, solicitanteFK, fotoFK, statusFK, dataFim)
values ('Cadeira quebrada', 'Roda de cadeira quebrada precisa ser trocada',
'2023-06-09', '2023-06-04', 3, 5, 4, 3, '2023-06-08');

insert into tarefa
(titulo, descricao, prazo, dataInicio, localFK, solicitanteFK, fotoFK, statusFK, dataFim)
values ('Interruptor de luz falhando', 'Interruptor do laboratório de informática 01 está falhando',
'2023-06-07', '2023-06-02', 5, 1, 5, 3, '2023-06-04');

insert into responsavel (responsavelFK, solicitanteFK, tarefaFK) values (2,4,1),(4,3,2),(5,3,3),(1,5,4),(3,1,5);

insert into historico (statusFK, tarefaFK, comentario, fotoFK) values
(1,1, 'Irei cuidar do problema assim que possível', 6),
(2,2, 'A questão já está sendo resolvida', 7),
(1,3, 'Já estou ciente da situação, resolverei em breve', 8),
(3,4, 'O defeito já foi solucionado', 9),
(3,5, 'Já solucionei a situação', 10);

select * from eventos;
select * from historico;
select * from foto;
select * from responsavel;
select * from tarefa;
select * from locais;
select * from usuarios;
select * from ocupacao;

-- ETAPA 2

-- 1 Crie uma consulta que mostre todas as tarefas ainda não iniciadas com as informações de seus respectivos envolvidos no processo;

select * from tarefa
inner join usuarios on usuarios.id = tarefa.solicitanteFK
inner join status on status.id = tarefa.statusFK where status.condicao = 1;

-- 2 Crie uma consulta que mostre todos os locais que não tiveram associação a nenhuma tarefa;

select locais.id, locais.nome
from locais
left join tarefa on locais.id = tarefa.localFK
where tarefa.localFK is null;

-- 3 Crie uma consulta que mostre todos os usuários que não tiveram associação a nenhuma tarefa;

select usuarios.id, usuarios.nome
from usuarios
where id not in (
  select solicitanteFK
  from tarefa
  union
  select responsavelFK
  from responsavel
);

-- 4 Crie uma consulta que mostre todos eventos que ainda acontecerão e as tarefas que ainda não foram executadas nos locais destes eventos (essa consulta ajudará a gestão visualizar se há algum problema que pode impactar os eventos);

select * from tarefa
inner join status on status.id = tarefa.statusFK
inner join locais on locais.id = tarefa.localFK
inner join eventos on locais.id = eventos.localFk
where eventos.inicio > tarefa.dataFim is null;

-- 5 Crie uma consulta que mostre os locais e a quantidade de tarefas existentes (independente do status);

select locais.id, locais.nome, COUNT(tarefa.id) as tarefas
from locais
left join tarefa on locais.id = tarefa.localFK
group by locais.id, locais.nome;

-- 6 Crie uma consulta que mostre os locais e a quantidade de tarefas não concluídas;

select locais.id, locais.nome, COUNT(tarefa.id) as tarefas
from locais
left join tarefa on locais.id = tarefa.localFK
where tarefa.statusFK < 3
group by locais.id, locais.nome;

-- 7 • Crie uma consulta que mostre os usuários e quantas tarefas possuem atribuídas (independente do status);

select usuarios.nome, COUNT(*) as tarefas
from (select solicitanteFK as usuario from responsavel
  union all
  select responsavelFK as usuario from responsavel
) as tds_usuarios
join usuarios on tds_usuarios.usuario = usuarios.id
group by usuarios.nome;


-- 8 Crie uma consulta que mostre os usuários e quantas tarefas possuem atribuídas a serem feitas;

select usuarios.nome, count(tarefa.id) tarefas
from responsavel
inner join tarefa on tarefa.id = responsavel.tarefaFK
inner join usuarios on usuarios.id = responsavel.responsavelFK
inner join status on status.id = tarefa.statusFK
where status.condicao < 3
group by usuarios.nome;

-- ETAPA 3

-- Um banco de dados do tipo NOSQL seria mais indicado pois possui maior flexibilidade no armazenamento
-- de diferentes tipos de arquivos podendo ser armazenados em um formato semelhante a documentos facilitando 
-- o acesso aos arquivos, além de possuir melhor escalabilidade horizontal, sendo mais facil de se adicionar
-- servidores adicionais no caso de um aumento de carga.



