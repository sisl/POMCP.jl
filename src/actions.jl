"""
    sparse_actions(pomcp::POMCPPlanner, pomdp::POMDPs.POMDP, h::BeliefNode, num_actions::Int)

Return an iterable object containing no more than `num_actions` actions to be considered at the current node.

Override this if you want to choose specific actions (you can override based on the POMDP type at the node level, or the belief type). If only a limited number of actions are to be considered, this function will be used to generate that set of actions. By default, it simply returns a random sampling of actions from the action space generated by `POMDPs.actions`.

If your problem has a continuous action space, you will want to override this to try a sensible set of action samples.
"""
function sparse_actions(pomcp::POMCPPlanner, pomdp::POMDPs.POMDP, h::BeliefNode, num_actions::Int)
    return sparse_actions(pomcp, pomdp, h.B, num_actions)
end

function sparse_actions(pomcp::POMCPPlanner, pomdp::POMDPs.POMDP, b::Any, num_actions::Int)
    if num_actions > 0
        all_act = collect(POMDPs.iterator(POMDPs.actions(pomdp, b)))
        selected_act = Array(Any, min(num_actions, length(all_act)))
        len = length(selected_act)
        for i in 1:len
            j = rand(pomcp.solver.rng, 1:length(all_act))
            selected_act[i] = all_act[j]
            deleteat!(all_act, j)
        end
        return selected_act
    else
        return POMDPs.iterator(POMDPs.actions(pomdp, b))
    end
end

"""
Generate a new action when the set of actions is widened.
"""
function next_action(gen::RandomActionGenerator, mdp::POMDPs.POMDP, b, hnode::BeliefNode)
    rand(gen.rng, POMDPs.actions(mdp, b))
end
next_action(f::Function, pomdp::POMDPs.POMDP, b, hnode::BeliefNode) = f(pomdp, s, snode)
