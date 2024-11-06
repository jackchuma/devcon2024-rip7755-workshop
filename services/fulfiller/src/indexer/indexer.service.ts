import { decodeEventLog, type Address } from "viem";

import chains from "../chain/chains";
import { SupportedChains } from "../common/types/chain";
import OutboxAbi from "../abis/RIP7755Outbox";
import type { RequestType } from "../common/types/request";
import SignerService from "../signer/signer.service";
import DBService from "../database/db.service";
import HandlerService from "../handler/handler.service";

export default class IndexerService {
  constructor(private readonly dbService: DBService) {}

  async handleLogs(sourceChain: SupportedChains, logs: any): Promise<void> {
    const calls = [];

    for (let i = 0; i < logs.length; i++) {
      calls.push(this.handleLog(sourceChain, logs[i]));
    }

    const responses = await Promise.allSettled(calls);

    for (let i = 0; i < responses.length; i++) {
      if (responses[i].status !== "fulfilled") {
        console.error("Error processing log", responses[i]);
      }
    }
  }

  private async handleLog(
    sourceChain: SupportedChains,
    log: any
  ): Promise<void> {
    const topics = decodeEventLog({
      abi: OutboxAbi,
      data: log.data,
      topics: log.topics,
    });

    console.log(topics);

    if (!topics.args) {
      throw new Error("Error decoding CrossChainCallRequested logs");
    }

    const { requestHash, request } = topics.args as {
      requestHash: Address;
      request: RequestType;
    };

    const activeChains = {
      src: chains[sourceChain],
      l1: chains[SupportedChains.MockEthereum],
      dst: chains[Number(request.destinationChainId)],
    };

    if (!activeChains.src) {
      throw new Error(`Invalid Source Chain: ${sourceChain}`);
    }
    if (!activeChains.l1) {
      throw new Error(`Invalid L1 Chain: ${SupportedChains.MockEthereum}`);
    }
    if (!activeChains.dst) {
      throw new Error(
        `Invalid Destination Chain: ${Number(request.destinationChainId)}`
      );
    }

    const signerService = new SignerService(activeChains.dst);
    const handlerService = new HandlerService(
      activeChains,
      signerService,
      this.dbService
    );

    await handlerService.handleRequest(requestHash, request);
  }
}
