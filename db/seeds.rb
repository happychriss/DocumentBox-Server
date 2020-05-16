# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
f=Folder.create(name: '1 - Nur Scannen', short_name: 'ScanOnly', cover_ind: false);
f.save
f=Folder.create(name: '2 - Ablegen in Ordner', short_name: 'Ablage', cover_ind: true);
f.save

