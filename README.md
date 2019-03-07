# Signature verification implementation for EIP712

*It is under development.*

## 概要

EIP712 の署名の仕組みを使用し、署名時にその内容を確認できる状態での署名を行わせるような実装を行う。

## 要点

署名の際に、本人のEOAアドレスを署名の対象として含める。

署名から得られるEOAアドレスが、署名内のEOAと同じものであれば、正しく本人が署名を行ったものであると確認ができる。

（署名内に EOA アドレスが無いものは、署名から得られたEOAアドレスが、正しい要求者のものなのか判断することが難しいため）

## 仕様

### トークン送金の代理実行実行の検証 : TokenExchangeVerification.sol

トークンの送金要求を署名し、代理者が署名から得られるEOAアドレスが一致していることを確認する。

ドメイン部：

```
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }
```

署名する値の型：

```solidity
    struct Exchange {
        address sender;
        uint256 amount;
        bytes32 key;
    }
```


### EIP712署名による本人認証 : Authentication.sol

サーバーから得られたシークレットキーとEOA(Externally Owned Account) アドレスによる署名を行う。
その署名から得られるEOAアドレスが一致していることを確認する。

ドメイン部：

```
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }
```

署名する値の型：

```solidity
    struct Auth {
        uint256 authId;
        address user;
        bytes32 key;
    }
```

- 認証したい EOA(Externally Owned Account) アドレスをWebAPIで送信し、IDとシークレットキーを発行する
- IDとシークレットキーとEOAアドレスの3つの値を EIP712 で署名する（署名時に使うEOAアドレスと、中に含まれるEOAアドレスが同じものとなる）
- ID・署名・EOAアドレス・シークレットキーをスマートコントラクトへ送信し署名時に使用したEOAアドレスを取得する
- 受け取ったEOAアドレスと署名から得られたEOAアドレスが一致していればEOAアドレスからの要求と判断する

![EIP712署名による本人認証](./docs/sequence-diagram/authentication-by-EIP712-signature.svg?s)

## 実装

実装は GitHub にて公開する。

https://github.com/godappslab/signature-verification

## 参考文献

**Standards**

1.  EIPs/eip-712.md at master · ethereum/EIPs https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
2.  EIP-712: eth_signTypedData as a standard for machine-verifiable and human-readable typed data signing
https://ethereum-magicians.org/t/eip-712-eth-signtypeddata-as-a-standard-for-machine-verifiable-and-human-readable-typed-data-signing/397
