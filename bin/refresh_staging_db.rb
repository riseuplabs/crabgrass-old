user = 'crabby'
db = 'brazil_development'
password = m3p3m3p3

# drop the database

`mysqldump -u#{user} -p#{password} --add-drop-table --no-data #{db} | grep ^DROP | mysql -u#{user} -p#{password} #{db}`

# export live data

`mysqldump brazil -u#{user} -p#{password} > ~/stopx.sql`

# import data

`mysql -u#{user} -p#{password} --database=#{db} --execute='source ~/stopx.sql'`


