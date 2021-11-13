using buddy.Should;

class TestClass1 {
    public function new() {}
}

class TestClass2 {
    public function new() {}
}

enum TestEnum1 {
    TEST;
}

abstract TestAbstract(Float) from Float to Float {
    public inline function new() {
        this = 1;
    }
}

typedef TestPoint = {x:Float, y:Float};

@:build(heat.ecs.WorldBuilder.registerComType(1, "LABEL"))
@:build(heat.ecs.WorldBuilder.registerComType(new TestAbstract()))
@:build(heat.ecs.WorldBuilder.registerComType({x:1, y:2}))
@:build(heat.ecs.WorldBuilder.registerComType({z:3}))
class TestWorld implements heat.ecs.IWorld {
    public function new() {
        this._comMap_LABEL[1] = 4;
        trace(getCom(1, LABEL));
    }
}

class Main extends buddy.SingleSuite {
    public function new() {
        describe("Worlds provide new, unique int IDs with getId() (starting with 1)", {
            describe("given a world", {
                var world = new heat.ecs.World();

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
                var world = new heat.ecs.World();

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
                var world = new heat.ecs.World();
                var id1:heat.ecs.EntityId = 1;
                var id2:heat.ecs.EntityId = 2;
                world.setClassCom(TestClass1, id1, new TestClass1());
                world.setClassCom(TestClass2, id1, new TestClass2());
                world.setClassCom(TestClass1, id2, new TestClass1());
                world.setClassCom(TestClass2, id2, new TestClass2());
                
                it("a query for those classes returns both IDs", {
                    var query = new heat.ecs.EntityQuery(world)
                    .with(TestClass1)
                    .with(TestClass2);
                    query.run();
                    query.result.should.containAll([id1, id2]);
                });
            });

            describe("given a world with two entities, one with two components, and another with only one", {
                var world = new heat.ecs.World();
                var id1:heat.ecs.EntityId = 1;
                var id2:heat.ecs.EntityId = 2;
                world.setClassCom(TestClass1, id1, new TestClass1());
                world.setClassCom(TestClass2, id1, new TestClass2());
                world.setClassCom(TestClass1, id2, new TestClass1());

                it("a query for those classes returns only the first ID", {
                    var query = new heat.ecs.EntityQuery(world)
                    .with(TestClass1)
                    .with(TestClass2);
                    query.run();
                    query.result.should.containExactly([id1]);
                });
            });

            describe("given a world with a component for some entity", {
                var world = new heat.ecs.World();
                var id1:heat.ecs.EntityId = 1;
                world.setClassCom(TestClass1, id1, new TestClass1());

                it("a query for a different component should not return that ID", {
                    var query = new heat.ecs.EntityQuery(world)
                    .with(TestClass2);
                    query.run();
                    query.result.should.not.contain(id1);
                });
            });

        });

        describe("macro tests", {
            var world = new TestWorld();
            var test:ComOption_TestWorld = null;
        });
    }
}