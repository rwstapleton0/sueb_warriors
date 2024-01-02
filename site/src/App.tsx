import { useState } from "react";
import { ConnectButton, useCurrentAccount, useSignAndExecuteTransactionBlock, useSuiClient } from "@mysten/dapp-kit";
import { KioskClient, KioskItem, KioskOwnerCap, Network } from "@mysten/kiosk";
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import "./styles.css";

import { useGetKioskData, useGetKiosks, imageUrls, SuebObject } from "./data";
import { KioskManager } from "./components/kioskManager";
import { MintSuebToKiosk } from "./components/mintSuebToKiosk";

interface SuebArenaProps {

}

function SuebArena(props: SuebArenaProps) {
    return (
        <Container py="3">
            <Heading size="7">Sueb Arena</Heading>
            <Container pt="6">
                <Flex gap="8" justify="center" align="center">
                    <Container className="sueb-frame" style={{ width: "248px", height: "392px" }} grow="0">
                        <Flex align="center">
                            <Container>The center</Container>
                        </Flex>
                    </Container>

                    <Heading>VS</Heading>

                    <Container className="sueb-frame" style={{ width: "248px", height: "392px" }} grow="0">
                        <Flex align="center">
                            <Container>The center</Container>
                        </Flex>
                    </Container>
                </Flex>

            </Container>

        </Container>
    )
}

function App() {
    const client = useSuiClient();
    const account = useCurrentAccount();

    const kioskClient = new KioskClient({
        client,
        network: Network.TESTNET,
    });

    const [kiosks, setKiosks] = useState<KioskOwnerCap[]>();
    const [selectedKiosk, setSelectedKiosk] = useState<KioskOwnerCap>();

    useGetKiosks(account, kioskClient, setKiosks);

    const [kioskItems, setkioskItems] = useState<KioskItem[]>();
    useGetKioskData(selectedKiosk, kioskClient, setkioskItems);

    // const [selectedSueb, setSelectedSueb] = useState<number>();

    let items: SuebObject[] = [];

    for (let i = 0; i < imageUrls.length; i++) {
        items.push({
            imageUrl: imageUrls[i],
            name: "Paul",
            energy: undefined,
            power: undefined,
            rush: undefined,
            objectId: undefined
        })
    }

    return (
        <Container px="4">
            <Flex
                py="2"
                justify="between"
                align="center"
            >
                <Box>
                    <Heading>Sueb Warriors</Heading>
                </Box>
                <Box>
                    <ConnectButton />
                </Box>
            </Flex>

            <KioskManager
                address={account?.address}
                kiosks={kiosks || []}
                selectedKiosk={selectedKiosk}
                setSelectedKiosk={setSelectedKiosk}
                kioskClient={kioskClient}
            />

            <MintSuebToKiosk
                kioskCap={selectedKiosk}
                kioskClient={kioskClient}
            />

            <SuebArena />

            {/* {selectedKiosk ? <MintSuebToKiosk
                kioskCap={selectedKiosk}
                kioskClient={kioskClient} /> : <></>}

            <KioskDataDisplay kioskItems={kioskItems || []} /> */}
        </Container>
    );
}

// get kiosk and mint sueb to kiosk

export default App;





// interface KioskDataDisplayProps {
//     kioskItems: KioskItem[]
// }

// function KioskDataDisplay(props: KioskDataDisplayProps) {
//     console.log(props.kioskItems)
//     const items = props.kioskItems.map((data: KioskItem, i: number) => (
//         <Heading className="hashHeading" key={i}>{data.objectId}</Heading>
//     ))
//     return (
//         <Container>
//             <Flex gap="2">
//                 {items}
//             </Flex>
//         </Container>
//     )
// }
