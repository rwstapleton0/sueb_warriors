import { useState } from "react";
import { useSignAndExecuteTransactionBlock } from "@mysten/dapp-kit";
import { KioskClient, KioskOwnerCap } from "@mysten/kiosk";
import { Container, Flex, Heading } from "@radix-ui/themes";
import { CaretDownIcon, CaretUpIcon } from "@radix-ui/react-icons";
import "../styles.css";

import { SuebObject, imageUrls, mintSuebInKiosk } from "../data";
import { SuebFrameList } from "./suebFrame";

interface MintSuebToKioskProps {
    kioskCap: KioskOwnerCap | undefined,
    kioskClient: KioskClient,
}

export function MintSuebToKiosk(props: MintSuebToKioskProps) {

    const { mutate: signAndExecuteTransactionBlock } = useSignAndExecuteTransactionBlock();

    const [showMint, setShowMint] = useState(false);
    const [selectedSueb, setSelectedSueb] = useState<number>();
    const [name, setName] = useState("Paul");

    let items: SuebObject[] = [];
    for (let i = 0; i < imageUrls.length; i++) {

        items.push({
            imageUrl: imageUrls[i],
            name: name,
            energy: undefined,
            power: undefined,
            rush: undefined,
            objectId: undefined
        })
    }

    return (
        <Container
            my="2"
            style={props.kioskCap ? { position: "relative" } : { borderBottom: "1px solid #575757" }}>
            <Container
                pb={"2"}
                style={!showMint ? { borderBottom: "1px solid #fff" } : {}}
                onClick={props.kioskCap ? () => setShowMint(!showMint) : () => { }}
            >
                <Flex justify="between" align="center">
                    <Heading style={props.kioskCap ? { color: "#fff" } : { color: "#575757" }} size="6">Mint a Sueb</Heading>
                    {
                        showMint == true
                            ? <CaretUpIcon width="32" height="32" />
                            : <CaretDownIcon style={props.kioskCap ? { color: "#fff" } : { color: "#575757" }} width="32" height="32" />
                    }
                </Flex>
            </Container>
            {
                showMint == true
                    ?
                    <Container style={{ width: "100%" }} position={"absolute"}>
                        <Container pb={"2"} style={props.kioskCap ? {
                            borderBottom: "1px solid #fff",
                            backgroundColor: "#111113"
                        } : {}}>
                            <Container py="2" pb="3" >
                                <SuebFrameList
                                    suebList={items}
                                    selectedSueb={selectedSueb}
                                    setSelectedSueb={setSelectedSueb}
                                />
                            </Container>
                            <Flex justify="between">
                                <Flex align="center" gap="2">
                                    <Heading>Give your Sueb a name: </Heading>
                                    <input type="text"
                                        style={{}}
                                        value={name}
                                        onChange={e => setName(e.target.value)}
                                    />
                                </Flex>
                                <button
                                    disabled={
                                        selectedSueb == undefined
                                        || name == undefined
                                        || props.kioskCap == undefined
                                    }
                                    style={{ width: "100%" }}
                                    onClick={() => mintSuebInKiosk(
                                        name, selectedSueb!, props.kioskCap!,
                                        props.kioskClient,
                                        signAndExecuteTransactionBlock
                                    )}
                                >
                                    <Heading className="hashHeading" size="3">Mint to Kiosk</Heading>
                                </button>
                            </Flex>
                        </Container>
                    </Container>
                    :
                    <></>
            }
        </Container>
    )
}
