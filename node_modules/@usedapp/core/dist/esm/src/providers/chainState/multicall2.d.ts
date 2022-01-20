import { Provider } from '@ethersproject/providers';
import { ChainCall } from './callsReducer';
import { ChainState } from './model';
export declare function multicall2(provider: Provider, address: string, blockNumber: number, requests: ChainCall[]): Promise<ChainState>;
//# sourceMappingURL=multicall2.d.ts.map