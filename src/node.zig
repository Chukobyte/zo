const zo = @import("zo");

const misc = zo.misc;

const TypeList = misc.TypeList;

pub const Node = struct {
    const Id = u32;

    const Interface = struct {
        interface_id: usize,
        instance: *anyopaque,
    };

    // id: GameObjectId,
    name: String,
    parent: ?*@This() = null,
};

pub const NodeSceneParams = struct {
    interface_types: []type,
};

pub fn NodeSceneSystem(params: NodeSceneParams) type {

    const NodeTypeList = TypeList(params.interface_types);

    return struct {


    };
}