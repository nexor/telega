module generator.generator;

import std.stdio : writeln, writefln;
import std.string : format;
import std.conv : to;
import generator.parser : TelegramEntity, TelegramType, TelegramMethod;
import std.array : join;
import std.algorithm.iteration : map, each;
import generator.language.declarations;
import generator.language.modules;
import generator.language.structs;

static string[string] entityModuleMap;

shared static this()
{
    string[] basic = [
        // types
        "User", "Chat", "Message", "Update",
        // methods
    ];
    string[] groupchat = [
        // types
        // methods
    ];
    string[] games = [
        // types
        "Game", "Animation", "CallbackGame", "GameHighScore",
        // methods
    ];

    basic.each!(val => entityModuleMap[val] = basic.stringof);
    games.each!(val => entityModuleMap[val] = games.stringof);
}

class CodeGenerator
{
    private string modulesDir = "telegram";
    private Module[string] modules;

    public this(string modulesDir)
    {
        this.modulesDir = modulesDir;
        foreach (telegramEntityName, moduleId; entityModuleMap) {
            if (moduleId !in modules) {
                modules[moduleId] = new Module(moduleId);
            }
        }
    }

    public void generateFiles(TelegramEntity[string] entities)
    {
        foreach (entity; entities) {
            if (entity.name !in entityModuleMap) {
                //writefln("Skipping %s", entity.id);

                continue;
            }
            assert(entity.name in entityModuleMap, format("Entity %s not found in entityModuleMap", entity.id));

            auto moduleObject = modules[entityModuleMap[entity.name]];

            if (auto telegramType = cast(TelegramType)entity) {
                moduleObject.addDeclDef(generateType(telegramType));
            } else if (cast(TelegramMethod)entity) {
                //generateMethod(cast(TelegramMethod)entity).writeln();
            } else {
                assert(false, "Unknown entity " ~ entity.name);
            }
        }

        foreach (moduleObject; modules) {
            writeln(moduleObject.to!string);
        }
    }

    private StructDeclaration generateType(TelegramType entity)
    {
        auto item = new StructDeclaration(entity.name);
        item.aggregateBody.addDeclDef(
            new VarDeclarations(
                new FundamentalType(FundamentalTypeEnum.Bool),
                new Declarators(
                    new DeclaratorInitializer(
                        new VarDeclarator("varname")
                    )
                )
            )
        );

        return item;
    }

    private string generateMethod(TelegramMethod entity)
    {
        return "TODO";
    }

}
