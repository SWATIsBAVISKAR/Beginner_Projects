create database projects;

use projects;

select * from hr;

alter table hr
change column ï»¿id emp_id varchar(20) null;

describe hr;

set sql_safe_updates = 0;

update hr
set birthdate = case
	when birthdate like '%/%' 
	then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
	when birthdate like '%-%' 
	then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else null
    end;
select birthdate from hr;

alter table hr
modify column birthdate date;

update hr
set hire_date = case
	when hire_date like '%/%' 
	then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
	when hire_date like '%-%' 
	then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    else null
    end;
    alter table hr
	modify column hire_date date;

    select hire_date from hr;
    
    update hr
    set termdate = date(str_to_date(termdate, '%Y-%m-%d%H:%i:%s UTC'))
    where termdate is not null and termdate!='0';
    
    select termdate from hr;
   
   alter table hr
	modify column termdate date;
	
    alter table hr
    add column age int;
    
    update hr
    set age = timestampdiff(year,birthdate,curdate());              -- Timestampdifference
    
    select birthdate,age from hr;                     -- MIN MAX
    select
    min(age) as youngest,
    max(age) as oldest 
    from hr;
    
    select count(*) from hr where age < 18;                  -- Age
									
    select gender, count(*) as count 
    from hr
    where age>=18 and termdate='0000-00-00'
    group by gender;                                          -- Gender 
							
    select race, count(*) as count 
    from hr
    where age>=18 and termdate='0000-00-00'
    group by race
    order by count(*) desc;
    
     select
    min(age) as youngest,
    max(age) as oldest 
    from hr
    where age>=18 and termdate='0000-00-00';
    
    select 
    case
    when age>=18 and age<=24 then '18-24'
    when age>=25 and age<=34 then '25-34'
    when age>=35 and age<=44 then '35-44'
    when age>=45 and age<=54 then '45-54'
    when age>=55 and age<=64 then '55-64'
    else '65+'
    end as age_group,
    count(*) as count
    from hr
    where age>=18 and termdate='0000-00-00'
    group by age_group
    order by age_group;
    
    select location from hr;
    
    select location,
    count(*)as count
    from hr
    where age>=18 and termdate='0000-00-00'
    group by location;
    
    select 
    round(avg(datediff(termdate,hire_date))/365,0) as avg_lenght_employeement
    from hr
    where termdate<=curdate() and termdate<>'0000-00-00' and age>=18;
    
	select jobtitle, count(*) as count 
    from hr
    where age>=18 and termdate='0000-00-00'
    group by jobtitle
    order by jobtitle desc;
    
    select department, total_count, terminated_count,
    terminated_count/total_count as  termination_rate
    from (
			select department, count(*) as total_count,
            sum(case when termdate<>'0000-00-00' and termdate<=curdate()then 1 else 0 end) as terminated_count
            from hr
            where age>=18
            group by department
            ) as subquery
            order by termination_rate desc;
            
            select location_state,count(*) as count
            from hr
            where age>=18 and termdate='0000-00-00'
            group by location_state
            order by count desc;
            
            select
            year,
            hires,
            terminations,
            hires-terminations as net_change,
            round((hires-terminations)/hires*100, 2) as net_change_percent
            from (select
            year(hire_date) as year,
            count(*) as hires,
             sum(case when termdate<>'0000-00-00' and termdate<=curdate()then 1 else 0 end) as terminations
             from hr
            where age>=18
            group by year(hire_date)
            ) as subquery
            order by year asc;
            
            select department,
            round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
            from hr 
             where termdate<=curdate() and termdate<>'0000-00-00' and age>=18
             group by department;
             
              select 
    case
    when age>=18 and age<=24 then '18-24'
    when age>=25 and age<=34 then '25-34'
    when age>=35 and age<=44 then '35-44'
    when age>=45 and age<=54 then '45-54'
    when age>=55 and age<=64 then '55-64'
    else '65+'
    end as age_group, gender,
    count(*) as count
    from hr
    where age>=18 and termdate='0000-00-00'
    group by age_group, gender
    order by age_group, gender;
    
    select 
    case
    when age>=18 and age<=24 then '18-24'
    when age>=25 and age<=34 then '25-34'
    when age>=35 and age<=44 then '35-44'
    when age>=45 and age<=54 then '45-54'
    when age>=55 and age<=64 then '55-64'
    else '65+'
    end as age_group, gender,department,
    count(*) as count
    from hr
    where age>=18 and termdate='0000-00-00'
    group by age_group, gender,department
    order by age_group, gender,department;
            