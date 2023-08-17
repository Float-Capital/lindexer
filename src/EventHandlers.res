open Types

let zeroAddress = Ethers.getAddressFromStringUnsafe("0x0000000000000000000000000000000000000000")

Handlers.ERC721Contract.Transfer.loader((~event, ~context) => {
  context.nftcollection.nftCollectionUpdatedLoad(event.srcAddress->Ethers.ethAddressToString)
  context.token.existingTransferredTokenLoad(
    event.srcAddress->Ethers.ethAddressToString ++ event.params.tokenId->Ethers.BigInt.toString,
    ~loaders={},
  )
})

Handlers.ERC721Contract.Transfer.handler((~event, ~context) => {
  let token = {
    id: `${event.srcAddress->Ethers.ethAddressToString}-${event.params.tokenId->Ethers.BigInt.toString}`,
    tokenId: event.params.tokenId,
    collection: event.srcAddress->Ethers.ethAddressToString,
    owner: event.params.to->Ethers.ethAddressToString,
    value: 1->Ethers.BigInt.fromInt,
    standard: "ERC721",
  }

  switch context.nftcollection.nftCollectionUpdated() {
  | Some(nftCollectionUpdated) =>
    let optExistingToken = context.token.existingTransferredToken()

    if optExistingToken->Belt.Option.isNone {
      //Update token collection supply since this is new NFT
      let currentSupply = nftCollectionUpdated.currentSupply + 1

      let updatedSupplyCollection = {
        ...nftCollectionUpdated,
        currentSupply,
      }

      context.nftcollection.set(updatedSupplyCollection)
    }
  | None =>
    //NFT collection doesn't exist yet
    //Initialize the collection
    let newNftCollection: Types.nftcollectionEntity = {
      id: event.srcAddress->Ethers.ethAddressToString,
      contractAddress: event.srcAddress->Ethers.ethAddressToString,
      //First NFT is being created so current suplly is 1
      currentSupply: 1,
      name: None,
      symbol: None,
      maxSupply: None,
    }

    context.nftcollection.set(newNftCollection)
  }

  if event.params.from !== zeroAddress {
    let userFrom = {
      id: event.params.from->Ethers.ethAddressToString,
    }
    context.user.set(userFrom)
  }

  if event.params.to !== zeroAddress {
    let userTo = {
      id: event.params.to->Ethers.ethAddressToString,
    }
    context.user.set(userTo)
    context.token.set(token)
  } else {
    //NFT has been burned
    context.token.delete(token.id)
  }
})

Handlers.ERC1155Contract.TransferSingle.loader((~event, ~context) => {
  context.nftcollection.nftCollectionUpdatedLoad(event.srcAddress->Ethers.ethAddressToString)
  context.token.existingTransferredTokenLoad(
    event.srcAddress->Ethers.ethAddressToString ++ event.params.id->Ethers.BigInt.toString,
    ~loaders={},
  )
})

Handlers.ERC1155Contract.TransferSingle.handler((~event, ~context) => {
  let token = {
    id: `${event.srcAddress->Ethers.ethAddressToString}-${event.params.id->Ethers.BigInt.toString}`,
    tokenId: event.params.id,
    collection: event.srcAddress->Ethers.ethAddressToString,
    owner: event.params.to->Ethers.ethAddressToString,
    value: event.params.value,
    standard: "ERC1155",
  }

  switch context.nftcollection.nftCollectionUpdated() {
  | Some(nftCollectionUpdated) =>
    let optExistingToken = context.token.existingTransferredToken()

    if optExistingToken->Belt.Option.isNone {
      //Update token collection supply since this is new NFT
      let currentSupply = nftCollectionUpdated.currentSupply + 1

      let updatedSupplyCollection = {
        ...nftCollectionUpdated,
        currentSupply,
      }

      context.nftcollection.set(updatedSupplyCollection)
    }
  | None =>
    //NFT collection doesn't exist yet
    //Initialize the collection
    let newNftCollection: Types.nftcollectionEntity = {
      id: event.srcAddress->Ethers.ethAddressToString,
      contractAddress: event.srcAddress->Ethers.ethAddressToString,
      //First NFT is being created so current suplly is 1
      currentSupply: 1,
      name: None,
      symbol: None,
      maxSupply: None,
    }

    context.nftcollection.set(newNftCollection)
  }

  if event.params.from !== zeroAddress {
    let userFrom = {
      id: event.params.from->Ethers.ethAddressToString,
    }
    context.user.set(userFrom)
  }

  if event.params.to !== zeroAddress {
    let userTo = {
      id: event.params.to->Ethers.ethAddressToString,
    }
    context.user.set(userTo)

    context.token.set(token)
  } else {
    //NFT has been burned
    context.token.delete(token.id)
  }
})

Handlers.ERC1155Contract.TransferBatch.loader((~event, ~context) => {
  context.nftcollection.nftCollectionUpdatedLoad(event.srcAddress->Ethers.ethAddressToString)
  event.params.ids->Belt.Array.forEach(id => {
    context.token.existingTransferredTokenLoad(
      event.srcAddress->Ethers.ethAddressToString ++ id->Ethers.BigInt.toString,
      ~loaders={},
    )
  })
})

Handlers.ERC1155Contract.TransferBatch.handler((~event, ~context) => {
  let _ = event.params.ids->Belt.Array.mapWithIndex((index, id) => {
    let token = {
      id: `${event.srcAddress->Ethers.ethAddressToString}-${id->Ethers.BigInt.toString}`,
      tokenId: id,
      collection: event.srcAddress->Ethers.ethAddressToString,
      owner: event.params.to->Ethers.ethAddressToString,
      value: event.params.values
      ->Belt.Array.get(index)
      ->Belt.Option.getWithDefault(1->Ethers.BigInt.fromInt),
      standard: "ERC1155",
    }

    switch context.nftcollection.nftCollectionUpdated() {
    | Some(nftCollectionUpdated) =>
      let optExistingToken = context.token.existingTransferredToken()

      if optExistingToken->Belt.Option.isNone {
        //Update token collection supply since this is new NFT
        let currentSupply = nftCollectionUpdated.currentSupply + 1

        let updatedSupplyCollection = {
          ...nftCollectionUpdated,
          currentSupply,
        }

        context.nftcollection.set(updatedSupplyCollection)
      }
    | None =>
      //NFT collection doesn't exist yet
      //Initialize the collection
      let newNftCollection: Types.nftcollectionEntity = {
        id: event.srcAddress->Ethers.ethAddressToString,
        contractAddress: event.srcAddress->Ethers.ethAddressToString,
        //First NFT is being created so current suplly is 1
        currentSupply: 1,
        name: None,
        symbol: None,
        maxSupply: None,
      }

      context.nftcollection.set(newNftCollection)
    }

    if event.params.from !== zeroAddress {
      let userFrom = {
        id: event.params.from->Ethers.ethAddressToString,
      }
      context.user.set(userFrom)
    }

    if event.params.to !== zeroAddress {
      let userTo = {
        id: event.params.to->Ethers.ethAddressToString,
      }
      context.user.set(userTo)

      context.token.set(token)
    } else {
      //NFT has been burned
      context.token.delete(token.id)
    }
  })
})
