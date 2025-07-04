# Tact template project

原项目：https://github.com/tact-lang/tact-template  
交互合约方式由blueprint浏览器连接钱包，修改为sendbox由ts文件直接发送



This template comes pre-configured to kickstart your new Tact project. It includes the Tact compiler, TypeScript, Jest integrated with [tact-emulator](https://github.com/tact-lang/tact-emulator), and a sample demonstrating how to run tests.

```shell
yarn test # To test contract
yarn build # To build contract
yarn lint # To find code issues in contract
yarn deploy # To deploy contract
```

## Deployment

To deploy a contract, follow these steps:

1. Define the [`contract.tact`](./sources/contract.tact) file that will be used as entry point of your contract.
2. Customize the [`contract.deploy.ts`](./sources/contract.deploy.ts) file based on your `contract.tact` to generate a deployment link. It is crucial to ensure the proper invocation of the `init()` function within the contract.

If you rename `contract.tact`, make sure to update [`tact.config.json`](./tact.config.json) correspondingly. Refer to the [Tact Documentation](https://docs.tact-lang.org/language/guides/config) for detailed information.

## Testing

You can find some examples of contract tests in [`contract.spec.ts`](./sources/contract.spec.ts). For more information about testing, see the [Tact Documentation](https://docs.tact-lang.org/language/guides/debug).

To add new test files to your contracts, you should create `*.spec.ts` files similar to the template's one and they would be automatically included in testing.

## License

MIT
