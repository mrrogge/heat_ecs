using buddy.Should;
using Lambda;

class TestClass1 {
    public function new() {}
}

class TestClass2 {
    public function new() {}
}

enum TestEnum1 {
    TEST;
}

class Main extends buddy.SingleSuite {
    public function new() {
        describe("ComQuery instances return all entity IDs with matching coms", {
            describe("given 2 com maps each with coms for the same 2 entities", {
                var map0 = new Map<heat.ecs.EntityId, TestClass1>();
                var map1 = new Map<heat.ecs.EntityId, TestClass2>();
                var id1:heat.ecs.EntityId = 1;
                var id2:heat.ecs.EntityId = 2;
                map0[id1] = new TestClass1();
                map0[id2] = new TestClass1();
                map1[id1] = new TestClass2();
                map1[id2] = new TestClass2();

                describe("and a ComQuery requiring those two coms", {
                    var query = new heat.ecs.ComQuery()
                        .with(map0)
                        .with(map1);
                    
                    it("that ComQuery should return both IDs", {
                        query.run();
                        query.result.should.containAll([id1, id2]);
                    });
                });
            });

            describe("given a com map with coms for two entities", {
                var map0 = new Map<heat.ecs.EntityId, TestClass1>();
                var id1:heat.ecs.EntityId = 1;
                var id2:heat.ecs.EntityId = 2;
                map0[id1] = new TestClass1();
                map0[id2] = new TestClass1();

                describe("and a com map with a com added for only one of those entities", {
                    var map1 = new Map<heat.ecs.EntityId, TestClass2>();
                    map1[id1] = new TestClass2();

                    describe("and a ComQuery requiring both coms", {
                        var query = new heat.ecs.ComQuery()
                            .with(map0)
                            .with(map1);

                        it("that ComQuery should return the ID with both coms", {
                            query.run();
                            query.result.should.contain(id1);
                        });

                        it("that ComQuery should not return the ID missing a com", {
                            query.run();
                            query.result.should.not.contain(id2);
                        });
                    });
                });
            });
        });

        describe('ComQuery instances should exclude entity IDs containing "without" coms', {
            describe("given a com map with coms for two entities", {
                var map0 = new Map<heat.ecs.EntityId, TestClass1>();
                var id1:heat.ecs.EntityId = 1;
                var id2:heat.ecs.EntityId = 2;
                map0[id1] = new TestClass1();
                map0[id2] = new TestClass1();

                describe("and a com map with a com added for only one of those entities", {
                    var map1 = new Map<heat.ecs.EntityId, TestClass2>();
                    map1[id1] = new TestClass2();

                    describe("and a ComQuery that requires the first com and excludes the second com", {
                        var query = new heat.ecs.ComQuery()
                            .with(map0)
                            .without(map1);
                        
                        it("that ComQuery should not return the ID with the excluded com", {
                            query.run();
                            query.result.should.not.contain(id1);
                        });

                        it("that ComQuery should return the ID without the excluded com", {
                            query.run();
                            query.result.should.contain(id2);
                        });
                    });
                });
            });
        });

        describe("ComQuery instances return all IDs with com values that match the specified whereEqualTo condition", {
            var map0 = new Map<heat.ecs.EntityId, String>();
            var id1 = 1;
            var id2 = 2;
            var valueToMatch = "matched value";
            map0[id1] = valueToMatch;
            map0[id2] = "Not the same value";
            var query = new heat.ecs.ComQuery().whereEqualTo(map0, valueToMatch);
            query.run();
            it("", {
                query.result.should.contain(id1);
            });
            it ("", {
                query.result.should.not.contain(id2);
            });
        });
    };
}