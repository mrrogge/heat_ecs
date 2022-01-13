package heat.ecs;

enum ComType<TClass, TEnum> {
    CLASS(cls:Class<TClass>);
    ENUM(enm:Enum<TEnum>);
    DYN(typeId:String);
}