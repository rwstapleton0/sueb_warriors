import { Container, Flex, Heading } from "@radix-ui/themes";
import { Crosshair2Icon } from "@radix-ui/react-icons";



function SuebArenaFrame() {
    return (
        <Container grow="0">
            <Container
                className="sueb-frame"
                style={{
                    width: "248px",
                    height: "392px",
                    paddingTop: "134px",
                    margin: "8px auto"
                }}

            >
                <Crosshair2Icon height="52" width="52" style={{ margin: "auto" }} />
                <Heading size="7" align="center">Click to add entry<br />your Sueb</Heading>
            </Container>
            <Flex gap="2" style={{ height: "42px" }}>
                <button>Energy</button>
                <button>Power</button>
                <button>Rush</button>
            </Flex>
        </Container>
    )
}

// interface SuebArenaProps {

// }

export function SuebArena() {
    return (
        <Container>
            <Heading size="7">Sueb Arena</Heading>
            <Container pt="2" pb="2">
                <Flex justify="center" align="center">
                    <SuebArenaFrame />
                    <Heading>VS</Heading>
                    <SuebArenaFrame />
                </Flex>
            </Container>
        </Container>
    )
}