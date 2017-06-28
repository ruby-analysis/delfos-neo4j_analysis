# Delfos::Neo4jAnalysis

Tools to make the Delfos recorded graph data more easily accessible.


## Usage (work in progress)

```
$ delfos_analysis
Choose an option
---------------
1. Find call sites for a single method
2. Step through an execution chain
3. List most heavily coupled classes with large file system distances

> 1
Enter Class & method e.g. `Product#name' or `Bundler.configure'
> Product#name
app/controllers/users_controller.rb:73
app/models/product_search.rb:14
app/models/user.rb:987
```
