# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
workshops = Workshop.create([ { description: 'Admin', color: 'rgb(220, 33, 39)' } ])

services = Service.create([
                              { name: 'FU', description: 'FormulaU - Новый автомобиль', base_time: 3.0, base_cost: 298 },
                              { name: 'MC', description: 'MachineClean™ & Dressing™', base_time: 0.3, base_cost: 30 },
                              { name: 'LR', description: 'LeatherResendre™', base_time: 3.0, base_cost: 0.0 },
                              { name: 'GS', description: 'GlassShield™', base_time: 0.3, base_cost: 39.6 }
                          ])



