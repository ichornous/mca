# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
services = Service.create([
                              { name: 'FU', cost: 1.0, time: 2.5 },
                              { name: 'SA', cost: 3.0, time: 1.0 },
                              { name: 'MT', cost: 1.2, time: 3.0 }
                          ])
events = Event.create([])