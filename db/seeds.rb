# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
workshops = Workshop.create([ { description: 'Kiev', color: 'rgb(220, 33, 39)' },
                              { description: 'Lviv', color: 'rgb(255, 184, 120)' } ])

services = Service.create([
                              { name: 'FU', description: 'FormulaU - Новый автомобиль', base_time: 3.0, base_cost: 298 },
                              { name: 'MC', description: 'MachineClean™ & Dressing™', base_time: 0.3, base_cost: 30 },
                              { name: 'LR', description: 'LeatherResendre™', base_time: 3.0, base_cost: 0.0 },
                              { name: 'GS', description: 'GlassShield™', base_time: 0.3, base_cost: 39.6 }
                          ])

clients = Client.create([
                            { name: 'Igor', phone: '+380123456789', workshop: workshops[0] },  # 0
                            { name: 'Thomas', phone: '+381123456789', workshop: workshops[0]}, # 1
                            { name: 'Justas', phone: '+382123456789', workshop: workshops[0]}, # 2
                            { name: 'Maxim', phone: '+383123456789', workshop: workshops[0]}   # 3
                        ])

cars = Car.create([
                      { description: 'Mercedes SLS', license_id: 'AA1234AA', workshop: workshops[0] }, # 0
                      { description: 'Citroen C4', license_id: 'AA5678AA', workshop: workshops[0] },   # 1
                      { description: 'Audi A4', license_id: 'AA9000AA', workshop: workshops[0] },      # 2
                      { description: 'Audi A3', license_id: 'AA9123AA', workshop: workshops[0] },      # 3
                      { description: 'VW Golf 7', license_id: 'AA0000AA', workshop: workshops[0] },    # 4
                      { description: 'Ford Kuga', license_id: 'AI1234IA', workshop: workshops[0] },    # 5
                  ])

orders = Order.create([
                          { client: clients[0], car: cars[1], state: 'NEW', workshop: workshops[0] },  # 0
                          { client: clients[0], car: cars[2], state: 'WORK', workshop: workshops[0] }, # 1
                          { client: clients[1], car: cars[0], state: 'DONE', workshop: workshops[0] }, # 2
                          { client: clients[1], car: cars[3], state: 'PAYED', workshop: workshops[0] },# 3
                          { client: clients[1], car: cars[3], state: 'PAYED', workshop: workshops[0] },# 4
                          { client: clients[2], car: cars[4], state: 'PAYED', workshop: workshops[0] },# 5
                          { client: clients[3], car: cars[5], state: 'WORK', workshop: workshops[0] }, # 6
                      ])

order_services = OrderService.create([
                                         { order: orders[0], service: services[0] },
                                         { order: orders[0], service: services[1] },
                                         { order: orders[1], service: services[0] },
                                         { order: orders[1], service: services[1] },
                                         { order: orders[1], service: services[2] },
                                         { order: orders[2], service: services[0] },
                                         { order: orders[3], service: services[1] },
                                         { order: orders[4], service: services[2] },
                                         { order: orders[4], service: services[0] },
                                         { order: orders[5], service: services[1] },
                                         { order: orders[6], service: services[2] },
                                     ])
visits = Visit.create([
                          {
                              car_name: orders[0].car.description,
                              description: 'Just a poor guy', client_name: 'Igor', phone_number: '+380123456789',
                              start_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              end_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              order: orders[0],
                              workshop: workshops[0]
                          },
                          {
                              car_name: orders[1].car.description,
                              description: 'Right from saloon', client_name: 'Igor', phone_number: '+380123456789',
                              start_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              end_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              order: orders[1],
                              workshop: workshops[0]
                          },
                          {
                              car_name: orders[2].car.description,
                              description: 'Not his car', client_name: 'Tom', phone_number: '+380000456789',
                              start_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              end_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              order: orders[2],
                              workshop: workshops[0]
                          },
                          {
                              car_name: orders[3].car.description,
                              description: 'Have already been here', client_name: 'Tom', phone_number: '+380000456789',
                              start_date: DateTime.new(2016, 4, 11, 12, 0, 0, '+2'),
                              end_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              order: orders[3],
                              workshop: workshops[0]
                          },
                          {
                              car_name: orders[4].car.description,
                              description: 'Is he a cat??', client_name: 'Tom', phone_number: '+380000456789',
                              start_date: DateTime.new(2016, 4, 11, 12, 0, 0, '+2'),
                              end_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              order: orders[4],
                              workshop: workshops[0]
                          },
                          {
                              car_name: orders[5].car.description,
                              description: 'Not his car', client_name: 'Justas', phone_number: '+382123456789',
                              start_date: DateTime.new(2016, 4, 11, 12, 0, 0, '+2'),
                              end_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              order: orders[5],
                              workshop: workshops[0]
                          },
                          {
                              car_name: orders[6].car.description,
                              description: 'Not his car', client_name: 'Maxim', phone_number: '+383123456789',
                              start_date: DateTime.new(2016, 4, 12, 12, 0, 0, '+2'),
                              end_date: DateTime.new(2016, 4, 13, 12, 0, 0, '+2'),
                              order: orders[6],
                              workshop: workshops[0]
                          },
                      ])


