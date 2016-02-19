# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

services = Service.create([
                              { name: 'FU', cost: 1.0, time: 2.5 },
                              { name: 'SA', cost: 3.0, time: 1.0 },
                              { name: 'MT', cost: 1.2, time: 3.0 }
                          ])


events = Event.create([
                          {
                              title: "Mercedes GLA 45 AMG", description: "Just a poor guy", client_name: "Vladimir", phone_number: "+380501230321",
                              start: DateTime.new(2016, 2, 20, 17, 30, 0, '+2'),
                              end: DateTime.new(2016, 2, 20, 20, 0, 0, '+2')
                          },
                          {
                              title: "Citroen C4", description: "SDE2 @ Amazon", client_name: "Igor", phone_number: "+380687770028",
                              start: DateTime.new(2016, 2, 21, 17, 30, 0, '+2'),
                              end: DateTime.new(2016, 2, 22, 20, 0, 0, '+2')
                          },
                      ])


event_services = EventService.create([
                                         { event: events[0], service: services[0] },
                                         { event: events[0], service: services[1] },
                                         { event: events[1], service: services[0] },
                                         { event: events[1], service: services[1] },
                                         { event: events[1], service: services[2] },
                                     ])