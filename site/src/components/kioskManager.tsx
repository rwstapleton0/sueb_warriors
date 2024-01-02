import { useSignAndExecuteTransactionBlock } from "@mysten/dapp-kit";
import { KioskClient, KioskOwnerCap } from "@mysten/kiosk";
import { Container, Flex, Heading } from "@radix-ui/themes";
import { createKiosk } from "../data";
import "../styles.css";

interface KioskButtonsProps {
    address: string | undefined,
    kiosks: KioskOwnerCap[],
    selectedKiosk: KioskOwnerCap | undefined,
    setSelectedKiosk: Function,
    kioskClient: KioskClient,
}

export function KioskManager(props: KioskButtonsProps) {
    const { mutate: signAndExecuteTransactionBlock } = useSignAndExecuteTransactionBlock();
    return (
        <Container py="3" style={{ borderBottom: "1px solid #fff"}}>
            {
                !props.selectedKiosk
                    ? <Flex gap="2">
                        <Heading size="8" style={{ minWidth: "220px" }}>Select Kiosk</Heading>
                        <Flex wrap="wrap" align="center" gap="2">
                            <button onClick={() => createKiosk(
                                props.address,
                                props.kioskClient,
                                signAndExecuteTransactionBlock
                            )}>
                                <Heading className="hashHeading" size="5">Create Kiosk</Heading>
                            </button>
                            {
                                props.kiosks?.map((kiosk: KioskOwnerCap, i: number) => (
                                    <button key={i} onClick={() => props.setSelectedKiosk(kiosk)}>
                                        <Heading className="hashHeading"
                                            size="5">{kiosk.kioskId}
                                        </Heading>
                                    </button>
                                ))
                            }
                        </Flex>
                    </Flex>
                    : <Flex gap="2" justify="between" align="center">
                        <Heading size="4" className="hashHeading">Selected Kiosk: {props.selectedKiosk.kioskId}</Heading>
                        <button
                            style={{
                                background: "#181818",
                                color: "#fff"
                            }}
                            onClick={() => props.setSelectedKiosk(undefined)}>
                            <Heading className="hashHeading" size="3">Select another Kiosk</Heading>
                        </button>
                    </Flex>
            }
        </Container>
    )
}