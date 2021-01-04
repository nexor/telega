module generator.generator;

import std.stdio : writeln, writefln;
import std.string : format;
import std.conv : to;
import generator.parser : TelegramEntity, TelegramType, TelegramMethod;
import std.array : join;
import std.algorithm.iteration : map, each;
import std.algorithm.searching : canFind;
import generator.language.declarations;
import generator.language.modules;
import generator.language.structs;

struct ModuleConfig
{
    public string[string] getEntityModuleMap(string[] enabledModules)
    {
        string[][string] moduleMap = [
            "basic": [
                // types
                "User", "Chat", "Message", "Update",
                // methods
            ],
            "groupchat": [

            ],
            "games": [
                // types
                "Game", "Animation", "CallbackGame", "GameHighScore",
                // methods
            ]
        ];

        string[string] result;

        foreach (const moduleName, const string[] moduleEntities; moduleMap) {
            if (enabledModules.length && !enabledModules.canFind(moduleName)) {
                continue;
            }
            moduleEntities.each!(val => result[val] = moduleName);
        }

        debug result = ["Update":"basic"];
        return result;
    }
}

class CodeGenerator
{
    private string modulesDir = "telegram";
    private Module[string] modules;
    private string[string] entityModuleMap;

    public this(string modulesDir, string[] enabledModules)
    {
        this.modulesDir = modulesDir;
        entityModuleMap = ModuleConfig().getEntityModuleMap(enabledModules);

        foreach (const telegramEntityName, const moduleId; entityModuleMap) {
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
