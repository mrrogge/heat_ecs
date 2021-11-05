using buddy.Should;
using Lambda;

class Main extends buddy.SingleSuite {
    public function new() {
        describe("ComQueries find all EntityIds with all components: ", {
            describe("given two ComMaps", {
                var map0 = new heat.ecs.ComMap<{}>();
                var map1 = new heat.ecs.ComMap<{}>();

                describe("and two entities with both components", {
                    var id0 = 0;
                    var id1 = 1;
                    map0[id0] = {};
                    map0[id1] = {};
                    map1[id0] = {};
                    map1[id1] = {};

                    it("a ComQuery result includes both entities.", {
                        var comQuery = new heat.ecs.ComQuery2(map0, map1);
                        comQuery.run();
                        //for some reason contain() and containAll() are not working with abstracts over enums, e.g:
                        //comQuery.result.should.containAll([id0, id1]);
                        //for now we just check item existence explicitly:
                        comQuery.result.exists(function(item) return item == id0).should.be(true);
                        comQuery.result.exists(function(item) return item == id1).should.be(true);
                    });
                });
            });
        });
            
        describe("ComQueries do not include EntityIds with missing components", {
            describe("given two ComMaps", {
                var map0 = new heat.ecs.ComMap<{}>();
                var map1 = new heat.ecs.ComMap<{}>();

                describe("and an entity with only one of the components", {
                    var id = 0;
                    map0[id] = {};

                    it("a ComQuery result should be empty", {
                        var comQuery = new heat.ecs.ComQuery2(map0, map1);
                        comQuery.run();
                        comQuery.result.exists(function(item) return item == id).should.be(false);
                    });
                });
            });
        });

        describe("ComQueries provide tuples of an entity's components: ", {
            describe("given an entity with two components", {
                var com0 = {value:0};
                var com1 = {value:1};
                var map0 = new heat.ecs.ComMap();
                var map1 = new heat.ecs.ComMap();
                var id = 0;
                map0[id] = com0;
                map1[id] = com1;
                
                it("a ComQuery should return a tuple containing both components", {
                    var comQuery = new heat.ecs.ComQuery2(map0, map1);
                    var comTuple = comQuery.getComTuple(id);
                    comTuple.e0.should.be(com0);
                    comTuple.e1.should.be(com1);
                });
            });

            describe("given an entity with only one of two components", {
                var com0 = {value:0};
                var map0 = new heat.ecs.ComMap();
                var map1 = new heat.ecs.ComMap<{}>();
                var id = 0;
                map0[id] = com0;
                
                it("a ComQuery should return a tuple containing the entity's component and a null", {
                    var comQuery = new heat.ecs.ComQuery2(map0, map1);
                    var comTuple = comQuery.getComTuple(id);
                    comTuple.e0.should.be(com0);
                    comTuple.e1.should.be(null);
                });
            });
        });

        describe("ComQueries reuse passed tuples when calling getComTuple(): ", {
            describe("given an entity with a component in a ComMap", {
                var map = new heat.ecs.ComMap();
                var id = 0;
                var com = {};
                map[id] = com;

                describe("and a ComQuery over that ComMap", {
                    var comQuery = new heat.ecs.ComQuery1(map);

                    it("the same tuple passed to getComTuple() should be returned", {
                        var comTuple = new heat.ecs.Tuple1<{}>();
                        comQuery.getComTuple(id, comTuple).should.be(comTuple);
                    });

                    it("an empty tuple passed to getComTuple() should have the component added", {
                        var comTuple = new heat.ecs.Tuple1<{}>();
                        comQuery.getComTuple(id, comTuple).e0.should.be(com);
                    });
                });
            });
        });

        describe("ComStores reuse components: ", {
            describe("given an empty ComStore", {
                var comStore = new heat.ecs.ComStore((?data:{}) -> return {});

                describe("and a component for an entity has been added and removed", {
                    var id = 1;
                    var com = comStore.add(id);
                    comStore.remove(id);

                    it("adding a component for a new entity should reuse the previous component", {
                        var otherId = 2;
                        var otherCom = comStore.add(otherId);
                        otherCom.should.be(com);
                    });
                });
            });
        });
    };
}