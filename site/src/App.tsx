import { useState } from "react";
import { ConnectButton, useCurrentAccount, useSuiClient } from "@mysten/dapp-kit";
import { KioskClient, KioskOwnerCap, Network } from "@mysten/kiosk";
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import "./styles.css";

import { useGetKiosks, imageUrls, SuebObject } from "./data";
import { KioskManager } from "./components/kioskManager";
import { MintSuebToKiosk } from "./components/mintSuebToKiosk";
import { SuebArena } from "./components/suebArenaFrame";


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

    // const [kioskItems, setkioskItems] = useState<KioskItem[]>();
    // useGetKioskData(selectedKiosk, kioskClient, setkioskItems);

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

        </Container>
    );
}

export default App;
