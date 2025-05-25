






This project encompasses the development of a C compiler for the CST-405, Principles of Compiler Design course at Grand Canyon University. The compiler executes semantic checks by categorizing them into those that can be solved immediately and those requiring function scope resolution. I implemented an instruction stack and an instruction struct to effectively manage semantic checks and function calls, implementing scope handling by deferring instruction processing until the function declaration is encountered.

Moreover, the compiler generates AST nodes during parsing and modifies them during instruction processing to handle tasks such as function returns. The design also incorporates conditional expression handling and IR code optimization. Through the application of constant folding and liveliness analysis techniques, the compiler enhances code optimization and management.