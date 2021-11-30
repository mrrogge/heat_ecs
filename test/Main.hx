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
        describe("Worlds provide new, unique int IDs with getId() (starting with 1)", {
            describe("given a world", {
                var world = new heat.ecs.dyn.World();

                it("returns 1 for the first ID", {
                    var expected:heat.ecs.EntityId = 1;
                    world.getId().should.equal(expected);
                });

                it("returns 2 for the next ID", {
                    var expected:heat.ecs.EntityId = 2;
                    world.getId().should.equal(expected);
                });
            });
        });

        describe("Worlds store and recall components for an ID", {
            describe("given a world", {
                var world = new heat.ecs.dyn.World();

                describe("and a stored class component", {
                    var testCom = new TestClass1();
                    var testId = 1;
                    world.setClassCom(TestClass1, testId, testCom);

                    it("returns the stored component for that ID", {
                        world.getClassCom(TestClass1, testId).should.equal(haxe.ds.Option.Some(testCom));
                    });
                });

                describe("and a stored enum component", {
                    var testCom:TestEnum1 = TEST;
                    var testId = 1;
                    world.setEnumCom(TestEnum1, testId, testCom);

                    it("returns the stored component for that ID", {
                        world.getEnumCom(TestEnum1, testId).should.equal(haxe.ds.Option.Some(testCom));
                    });
                });
            });
        });

        describe("Queries return IDs that meet all criteria", {
            describe("given a world with two entities, each with two components", {
                var world = new heat.ecs.dyn.World();
                var id1:heat.ecs.EntityId = 1;
                var id2:heat.ecs.EntityId = 2;
                world.setClassCom(TestClass1, id1, new TestClass1());
                world.setClassCom(TestClass2, id1, new TestClass2());
                world.setClassCom(TestClass1, id2, new TestClass1());
                world.setClassCom(TestClass2, id2, new TestClass2());
                
                it("a query for those classes returns both IDs", {
                    var query = new heat.ecs.dyn.EntityQuery(world)
                    .with(TestClass1)
                    .with(TestClass2);
                    query.run();
                    query.result.should.containAll([id1, id2]);
                });
            });

            describe("given a world with two entities, one with two components, and another with only one", {
                var world = new heat.ecs.dyn.World();
                var id1:heat.ecs.EntityId = 1;
                var id2:heat.ecs.EntityId = 2;
                world.setClassCom(TestClass1, id1, new TestClass1());
                world.setClassCom(TestClass2, id1, new TestClass2());
                world.setClassCom(TestClass1, id2, new TestClass1());

                it("a query for those classes returns only the first ID", {
                    var query = new heat.ecs.dyn.EntityQuery(world)
                    .with(TestClass1)
                    .with(TestClass2);
                    query.run();
                    query.result.should.containExactly([id1]);
                });
            });

            describe("given a world with a component for some entity", {
                var world = new heat.ecs.dyn.World();
                var id1:heat.ecs.EntityId = 1;
                world.setClassCom(TestClass1, id1, new TestClass1());

                it("a query for a different component should not return that ID", {
                    var query = new heat.ecs.dyn.EntityQuery(world)
                    .with(TestClass2);
                    query.run();
                    query.result.should.not.contain(id1);
                });
            });
        });
        var x = new heat.ecs.ComQueryAlt2<Int, String>(
            new Map<heat.ecs.EntityId, Int>(),
            new Map<heat.ecs.EntityId, String>()
        );
    };
}