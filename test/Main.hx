using buddy.Should;

class World3 extends heat.ecs.World2 {
    override public function new() {
        super();
    }

    registerComType();
}

class Main extends buddy.SingleSuite {
    public function new() {
        describe("temp", {
            it("temp", {
                var world = new heat.ecs.World();
                var world2 = new heat.ecs.World2();
                world2.registerComType();
            });
        });
    }
}