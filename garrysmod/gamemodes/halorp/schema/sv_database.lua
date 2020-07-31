GM = GM or GAMEMODE

function GM:SetupDatabase()
	-- Which method of storage: sqlite, tmysql4, mysqloo
	nut.db.module = "sqlite"
	-- The hostname for the MySQL server.
	nut.db.hostname = "45.87.80.52"
	-- The username to login to the database.
	nut.db.username = "u934747185_admin"
	-- The password that is associated with the username.
	nut.db.password = "1MasterWork1"
	-- The database that the user should login to.
	nut.db.database = "u934747185_nexus_ns"
	-- The port for the database, you shouldn't need to change this.
	nut.db.port = 3306
end
