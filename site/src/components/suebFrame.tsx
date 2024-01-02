import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import { SuebObject } from "../data";
import "../styles.css"

interface SuebFrameProps {
    sueb: SuebObject,
    isSelected: boolean,
    setSelectedSueb: Function
}

export function SuebFrame(props: SuebFrameProps) {
    props.isSelected ? console.log("hello") : ""
    return (
        <Container
            grow="0"
            p="3"
            className={`sueb-frame ${props.isSelected ? "selected" : ""}`}
            onClick={() => props.setSelectedSueb()}
        >
            <Container p="2" style={{ height: "46px"}}>
                <Heading>{props.sueb.name}</Heading>
            </Container>
            <Container 
            mb="2"
            style={{
                width: "220px",
                height: "220px",
                border: "2px solid #fff",
                borderRadius: "10px"
            }}>
                {/* <img src={`../assets/sueb_w${props.index}.png`} /> */}
                {/* <img crossOrigin='anonymous' src={"https://pub-e4480e97f3884c27b323b3f1273cd96b.r2.dev/sueb-warriors/pngs/sueb_w1.png"} /> */}
            </Container>
            <Flex justify="between">
                <Heading>Energy:</Heading>
                <Heading>{props.sueb.energy ?? "??"}</Heading>
            </Flex>
            <Flex justify="between">
                <Heading>Power:</Heading>
                <Heading>{props.sueb.power ?? "??"}</Heading>
            </Flex>
            <Flex justify="between">
                <Heading>rush:</Heading>
                <Heading>{props.sueb.rush ?? "??"}</Heading>
            </Flex>
        </Container>
    )
}

interface SuebFrameListProps {
    suebList: any[]
    selectedSueb: number | undefined,
    setSelectedSueb: Function,
}

export function SuebFrameList(props: SuebFrameListProps) {

    const items = props.suebList.map((sueb: SuebObject, i: number) => (
        <SuebFrame
            key={i}
            sueb={sueb}
            isSelected={i == props.selectedSueb}
            setSelectedSueb={() => props.setSelectedSueb(i)}
        />
    ))
    return (
        <Container>
            <Flex gap="2" justify="between">
                {items}
            </Flex>
        </Container>
    )
}