import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new moodboard",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("moodboard", "create-moodboard", [
        types.utf8("My Moodboard"),
        types.utf8("Description"),
        types.bool(true)
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    block.receipts[0].result.expectOk().expectUint(1);
  }
});

Clarinet.test({
  name: "Can update item position",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    // First create a moodboard and add an item
    let block = chain.mineBlock([
      Tx.contractCall("moodboard", "create-moodboard", [
        types.utf8("Test Moodboard"),
        types.utf8("Description"),
        types.bool(true)
      ], wallet_1.address),
      Tx.contractCall("moodboard", "add-item", [
        types.uint(1),
        types.utf8("https://example.com/image.jpg"),
        types.uint(100),
        types.uint(100)
      ], wallet_1.address)
    ]);
    
    // Then update the item position
    block = chain.mineBlock([
      Tx.contractCall("moodboard", "update-item", [
        types.uint(1),
        types.uint(0),
        types.uint(200),
        types.uint(200)
      ], wallet_1.address)
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
  }
});
