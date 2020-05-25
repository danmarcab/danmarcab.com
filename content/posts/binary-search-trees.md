---
{
  "type": "post",
  "title": "Binary search trees (BST)",
  "description": "This is a no-code explanation of how plain binary trees work and their use cases.",
  "image": "/images/article-covers/bst.png",
  "draft": false,
  "published": "2020-06-25"
}
---

In this post I will try to explain what a binary search tree is, how
they work and how useful they are for many problems. In future posts I plan
to analyze a couple of more advanced BSTs. 

But first, let's start describing a plain binary tree.

## What is a binary tree?

A binary tree is a data structure where we store our items in a hierarchical
way, where a parent node can have at most two children.

<custom-figure description="Two examples of binary trees">
<simple-tree preorder="7 10 -3 l l 5 15 l l 10 l l 9 l l"/>
<simple-tree preorder="5 16 3 l l l 1 l l"/>
</custom-figure>

We can store anything in a binary tree, but in this
simple form they are not very useful.

## What is a binary search tree (BST)?

A binary search tree is a binary tree where we add an additional invariant: 

Given a node `n` with value `v`, all values on the left subtree are smaller
than `v`, and all values on the right subtree are greater than `v`.

<custom-figure description="Two examples of binary search trees">
<simple-tree preorder="10 5 3 l l 6 l l 12 11 l l 17 14 l l l"/>
<simple-tree preorder="5 3 1 l l l 10 l 12 l l"/>
</custom-figure>

If you analyze any node above, you can see they all follow the rule,
for example: 

- Node 12 on the right tree has 11 on its left which is smaller, and 17 and 14 on its right which are greater. Additionally note that 14 is the left child of 17, because it is smaller.

If we were to traverse the tree using [in-order](https://en.wikipedia.org/wiki/Tree_traversal)
we would get the items ordered from smallest to greatest.

This invariant has another two consequences: 
- A BST can only store items we can compare and order (numbers, names, etc.).
- All values will be unique, since no value is greater or smaller than itself.

## Ok, but what are they used for?

The clue is on the name, binary *search* trees. They allow to search elements in
the tree using binary search. Binary search is fast because in each step half of the
elements are discarded. For more details about this operation, please keep reading.

They are also great to implement sets of items, since the properties are great for that use case:
- Holds only unique items.
- Fast lookup to test if a value is a member of the set.
- Fast insertion of a new value.
- Fast deletion a existing value.

With minimal changes they can be used to implement dictionaries: key value
data structures where you can retrieve a data element by a key. For example, 
we could store a user record with name, email, telephone etc. using a unique
id of the user as a key. We would then use this key in the tree operations to
decide where to store the data.

## How do they work?

Now that we know the invariants we need to maintain we can analyze how the
operations work. We will cover the three basic operations: lookup, insertion
and deletion.

### Lookup

The way the values are arranged makes the lookup a very simple operation, we can
use [binary search](https://en.wikipedia.org/wiki/Binary_search_algorithm) directly.

Since we know that for a given node, all values to the left are smaller, and all values to
the right are greater, we can eliminate one of the subtrees on each step.

Let's look at an example, lookup of 14 in the following tree.

<custom-figure description="Lookup 14: 14 > 10 so we go right, 14 < 15 so we go left, 14 > 13 so we go right, found 14">
<simple-tree preorder="10 5 2 1 l l 3 l l 7 6 l l 9 l l 15 13 11 l l 14 l l 17 16 l l 21 l l" highlight-edges-to="15:b 13:b 14:b" highlight-nodes="10:b 15:b 13:b 14:g"/>
</custom-figure>

Now let's lookup for 8, which is not in the tree.
<custom-figure description="Lookup 8: 8 < 10 so we go left, 8 > 5 so we go right, 8 > 7 so we go right, 9 is a leaf, 8 is not in the tree">
<simple-tree preorder="10 5 2 1 l l 3 l l 7 6 l l 9 l l 15 13 11 l l 14 l l 17 16 l l 21 l l" highlight-edges-to="5:b 7:b 9:b" highlight-nodes="10:b 5:b 7:b 9:o"/>
</custom-figure>

From these examples we can clearly see that we don't have to go through all elements of the tree
one by one, exploiting the properties of the BST we can have a result quickly.

### Insertion

To insert an item, we build on top of lookup, making sure we respect the invariant. We can find a couple of different cases.

If the item is already in the tree, we do nothing.

<custom-figure description="Insert 3: 3 < 5 so we go left, 3 > 2 so we go right, we found 3, so we do nothing">
<simple-tree preorder="5 2 1 l l 3 l l 7 6 l l 9 l l" highlight-edges-to="2:b 3:b" highlight-nodes="5:b 2:b 3:o"/>
</custom-figure>

If we reach a node where the lookup algorithm tells us to pick a direction 
and the node doesn't have a subtree on that direction, we create a subtree
on that direction with the node we want to insert.

<custom-figure description="Insert 6: 6 > 5 so we go right, 6 < 7 and 7 has no left subtree, we insert 6 on the left">
<simple-tree preorder="5 2 1 l l 3 l l 7 6 l l 9 l l" highlight-edges-to="6:g" highlight-nodes="6:g"/>
<simple-tree preorder="5 2 1 l l 3 l l 7 l 9 l l" highlight-edges-to="7:b" highlight-nodes="5:b 7:g"/>
</custom-figure>


<custom-figure description="Insert 4: 4 < 5 so we go left, 4 > 2 so we go right, 4 > 3 and 3 has no left subtree, so we insert 4 there">
<simple-tree preorder="5 2 1 l l 3 4 l l l 7 l 9 l l" highlight-edges-to="4:g" highlight-nodes="4:g"/>
<simple-tree preorder="5 2 1 l l 3 l l 7 l 9 l l" highlight-edges-to="2:b 3:b" highlight-nodes="5:b 2:b 3:b"/>
</custom-figure>

### Deletion

Deletion also builds on lookup, but it's probably the trickiest operation. We can remove a node
on any position of the tree, but to maintain the invariant we may need to rearrange the tree.

Let's go case by case, starting with the easiest, when the value is not in the tree.

#### When the element is not contained in the tree

We would apply the same lookup algorithm and find out the element is not in tree. Nothing else
to do.

#### When the element to delete is a leaf

If we apply the lookup algorithm and find out the node is a leaf (it doesn't have any children)
we can just delete the node.

<custom-figure description="Delete 3: 3 < 5 so we go left, 3 > 2 so we go right, found 3, is a leaf so we delete it">
<simple-tree preorder="5 2 1 l l l 7 l 9 l l"/>
<simple-tree preorder="5 2 1 l l 3 l l 7 l 9 l l" highlight-edges-to="2:b 3:r" highlight-nodes="5:b 2:b 3:r"/>
</custom-figure>

#### When the element to delete has only one child

In the case the node has only one child, we can delete the node and replace it with
the child. Let's look at some examples.

<custom-figure description="Delete 7: 7 > 5 so we go right, found 7, has only one child so delete 7 and replace it with its child">
<simple-tree preorder="5 2 1 l l 3 l l 9 l l" highlight-edges-to="9:m" highlight-nodes="9:m"/>
<simple-tree preorder="5 2 1 l l 3 l l 7 l 9 l l" highlight-edges-to="7:r 9:m" highlight-nodes="5:b 7:r 9:m"/>
</custom-figure>

A node can have only one child, but its child can be an arbitrarily big subtree. The rule is still just replace
the node with its child.

<custom-figure description="Delete 4: 4 < 5 so we go left, 4 has only one child, so we delete it and replace with its child">
<simple-tree preorder="5 2 1 l l 3 l l 7 l 9 l l" highlight-edges-to="2:m 1:m 3:m" highlight-nodes="2:m 1:m 3:m"/>
<simple-tree preorder="5 4 2 1 l l 3 l l l 7 l 9 l l" highlight-edges-to="4:r 2:m 1:m 3:m" highlight-nodes="5:b 4:r 2:m 1:m 3:m"/>
</custom-figure>

#### When the element to delete has both children

In the case where the element has both children, it's a bit more complex. 

We will begin with the simplest case, where both children are leaf. In this case we could replace
the node we are deleting with any of the children. We chose to replace it with the right child,
but it's an arbitrary decision.

<custom-figure description="Delete 2: 2 < 5 so we go left, 2 has both children, so we delete it and replace with its right child, 3">
<simple-tree preorder="5 3 1 l l l 7 l 9 l l" highlight-edges-to="2:r 1:m 3:m" highlight-nodes="5:b 2:r 1:m 3:m"/>
<simple-tree preorder="5 2 1 l l 3 l l 7 l 9 l l" highlight-edges-to="2:r 1:m 3:m" highlight-nodes="5:b 2:r 1:m 3:m"/>
</custom-figure>

In the general case, where one or both children are arbitrary subtrees, the rule is as follows:
We need to find the successor (the next if we follow the order) of the element we want to delete.
In a binary search tree this means finding the leftmost element of the right subtree. The right
subtree contains all elements greater than the element we want to delete, and the leftmost is
the smaller amongst them. Let's call it `m`.

Once we find it, there are two different cases:

**Case 1:** `m` is a leaf

When `m` is a leaf, we just need to replace the node we want to delete with `m`.


<custom-figure description="Delete 10: we find the leftmost node of the right subtree, in this case 11, and put it in place of 10">
<simple-tree preorder="11 5 2 l 3 l l 7 6 l l l 15 13 l l 17 16 l l l" highlight-nodes="11:m"/>
<simple-tree preorder="10 5 2 l 3 l l 7 6 l l l 15 13 11 l l l 17 16 l l l" highlight-edges-to="15:m 13:m 11:m" highlight-nodes="10:r 11:m"/>
</custom-figure>

**Case 2:** `m` has a right child

By definition, `m` can only have a right child, because if it had a left child it wouldn't be the leftmost child.
In this case we need to do two things:
- As in the case before, replace the element to delete with `m`.
- 'Promote' the right subtree of `m`, putting it where `m` was.

<custom-figure description="Delete 5: we find the leftmost node of the right subtree (6) and replace 5 with it, the right subtree of 6 goes one level up where 6 was">
<simple-tree preorder="10 6 2 l l 8 7 l l 9 l l 15 l l" highlight-edges-to="7:o 9:o" highlight-nodes="10:b 5:r 6:m 7:o 8:o 9:o"/>
<simple-tree preorder="10 5 2 l l 6 l 8 7 l l 9 l l 15 l l" highlight-edges-to="7:o 9:o" highlight-nodes="10:b 5:r 6:m 7:o 8:o 9:o"/>
</custom-figure>


## Balance and performance

Our binary search tree performs really well, allowing us to use binary search, which means
all operations are of order `O(log n)`. This means the execution time is proportional to the
height of the tree.

But, there is a catch, for this to be true, the tree needs to be balanced. A balanced tree is
one where the left and right subtrees of every node differ in height by a max of 1.

<custom-figure description="Two balanced trees">
<simple-tree preorder="5 2 1 l l 3 l l 9 l l"/>
<simple-tree preorder="5 2 1 l l 3 l l 7 6 l l 9 l l"/>
</custom-figure>

Any binary search tree that does not meet that requirement in considered *unbalanced*. To
clearly see how this affects the performance, let's look at the next example:

<custom-figure description="A degenerate tree, will behave like a linked list">
<simple-tree preorder="1 l 2 l 3 l 4 l 5 l 6 l 7 l l"/>
</custom-figure>

The degenerate tree behaves like a linked list, meaning all operations are `O(n)`, since in
the worst case all elements will be visited.

You can easily run into these cases, the tree from the example is the result of inserting
the elements from 1 to 7 using the insertion procedure explained before.

It is so important for binary search tree to be balanced that there are several enhanced
tree data structures called self-balancing binary search trees. *AVL trees* and *red-black trees*
are two classic examples, each using a different strategy to keep the tree balanced.

In the next post, we'll concentrate on *AVL trees*.
